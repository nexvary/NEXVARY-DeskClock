#include "Recording.hpp"

#include "ScenarioLoader.hpp"

#include <QBuffer>
#include <QCoreApplication>
#include <QCryptographicHash>
#include <QDataStream>
#include <QDir>
#include <QFileInfo>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QSaveFile>

#include <cmath>

namespace aeroradar::recording {
namespace {

const QByteArray magic("AERORAD1");
constexpr qsizetype digestBytes = 32;
constexpr qint64 maxMetadataBytes = 2 * 1024 * 1024;
constexpr qint64 sampleBytes = 5 * 8;
constexpr qint64 maxFileBytes = maxMetadataBytes + maxSamples * sampleBytes + 64;
constexpr double maxTick = 9007199254740991.0 - maxFrames;

QString message(const char* text) {
    return QCoreApplication::translate("RecordingFile", text);
}

QString localPath(const QUrl& url) {
    if (!url.isLocalFile() || !url.host().isEmpty())
        return {};
    const auto path = QDir::fromNativeSeparators(url.toLocalFile());
    return !path.startsWith(QLatin1String("//")) && QDir::isAbsolutePath(path)
        ? path : QString{};
}

void configure(QDataStream& stream) {
    stream.setVersion(QDataStream::Qt_6_0);
    stream.setByteOrder(QDataStream::LittleEndian);
    stream.setFloatingPointPrecision(QDataStream::DoublePrecision);
}

bool validSample(const Sample& sample) {
    constexpr double metersPerNauticalMile = 1852.0;
    return std::isfinite(std::hypot(sample.eastKm, sample.northKm)) &&
        std::isfinite(sample.altitudeM) &&
        std::isfinite(std::hypot(sample.eastKmPerSecond, sample.northKmPerSecond)
                      * (3600000.0 / metersPerNauticalMile));
}

QJsonObject metadata(const Recording& recording) {
    QJsonArray bookmarks;
    for (const auto& bookmark : recording.bookmarks)
        bookmarks.append(QJsonObject{{"frame", bookmark.frame}, {"label", bookmark.label}});
    return {{"scenario", recording.scenario}, {"capturedUtc", recording.capturedUtc.toString(Qt::ISODateWithMs)},
            {"firstTick", static_cast<qint64>(recording.firstTick)}, {"tickMs", tickMs},
            {"source", "synthetic"}, {"engine", "local-planar-v1"}, {"randomSeed", QJsonValue::Null},
            {"frames", recording.frameCount()}, {"bookmarks", bookmarks}, {"notes", recording.notes}};
}

} // namespace

int Recording::frameCount() const {
    return identities.empty() ? 0 : static_cast<int>(samples.size() / identities.size());
}

bool Recording::atCapacity() const {
    return frameCount() >= maxFrames || samples.size() + identities.size() > maxSamples;
}

void Recording::appendFrame(const std::vector<Aircraft>& aircraft) {
    for (const auto& track : aircraft)
        samples.push_back({track.x_km, track.y_km, track.altitude_m, track.vx_km_s, track.vy_km_s});
}

Sample Recording::sample(int frame, std::size_t track) const {
    return samples[static_cast<std::size_t>(frame) * identities.size() + track];
}

bool save(const QUrl& url, const Recording& recording, QString& error) {
    const auto path = localPath(url);
    const QFileInfo destination(path);
    if (path.isEmpty() || destination.isSymLink() ||
        (destination.exists() && !destination.isFile())) {
        error = message("Choose a regular local recording file.");
        return false;
    }
    const auto header = QJsonDocument(metadata(recording)).toJson(QJsonDocument::Compact);
    if (recording.frameCount() == 0 || recording.frameCount() > maxFrames ||
        recording.samples.size() > maxSamples ||
        recording.samples.size() % recording.identities.size() != 0 || header.size() > maxMetadataBytes ||
        static_cast<double>(recording.firstTick) > maxTick) {
        error = message("The recording is empty or exceeds its format limits.");
        return false;
    }

    QByteArray bytes = magic;
    QDataStream stream(&bytes, QIODevice::Append);
    configure(stream);
    stream << quint32(header.size());
    stream.writeRawData(header.constData(), static_cast<int>(header.size()));
    for (const auto& sample : recording.samples) {
        if (!validSample(sample)) {
            error = message("The recording contains an invalid aircraft sample.");
            return false;
        }
        stream << sample.eastKm << sample.northKm << sample.altitudeM
               << sample.eastKmPerSecond << sample.northKmPerSecond;
    }
    if (stream.status() != QDataStream::Ok) {
        error = message("The recording could not be encoded.");
        return false;
    }
    bytes.append(QCryptographicHash::hash(bytes, QCryptographicHash::Sha256));

    QSaveFile file(path);
    if (!file.open(QIODevice::WriteOnly) || file.write(bytes) != bytes.size() || !file.commit()) {
        error = message("The recording could not be saved.");
        return false;
    }
    error.clear();
    return true;
}

std::optional<Recording> load(const QUrl& url, QString& error) {
    const auto fail = [&error](const char* text) -> std::optional<Recording> {
        error = message(text);
        return std::nullopt;
    };
    const auto path = localPath(url);
    if (path.isEmpty() || !QFileInfo(path).isFile())
        return fail("Choose a regular local recording file.");
    QFile file(path);
    if (!file.open(QIODevice::ReadOnly))
        return fail("The recording could not be opened.");
    if (file.size() > maxFileBytes)
        return fail("The recording exceeds its file size limit.");
    auto bytes = file.read(maxFileBytes + 1);
    if (file.error() != QFileDevice::NoError || bytes.size() > maxFileBytes)
        return fail("The recording could not be read within its file size limit.");
    if (bytes.size() <= magic.size() + 4 + digestBytes || !bytes.startsWith(magic))
        return fail("Unsupported or incomplete recording format.");
    const auto digest = bytes.last(digestBytes);
    bytes.chop(digestBytes);
    if (QCryptographicHash::hash(bytes, QCryptographicHash::Sha256) != digest)
        return fail("Recording checksum mismatch.");

    QBuffer buffer(&bytes);
    buffer.open(QIODevice::ReadOnly);
    buffer.seek(magic.size());
    QDataStream stream(&buffer);
    configure(stream);
    quint32 headerSize{};
    stream >> headerSize;
    if (headerSize > maxMetadataBytes || headerSize > buffer.bytesAvailable())
        return fail("Invalid recording metadata size.");
    const auto root = QJsonDocument::fromJson(buffer.read(headerSize)).object();
    const int frames = root.value("frames").toInt();
    const double first = root.value("firstTick").toDouble(-1);
    Recording result;
    result.scenario = root.value("scenario").toString();
    result.capturedUtc = QDateTime::fromString(root.value("capturedUtc").toString(), Qt::ISODateWithMs);
    const auto bookmarks = root.value("bookmarks").toArray();
    result.notes = root.value("notes").toString();
    if (frames < 1 || frames > maxFrames || !(first >= 0 && first <= maxTick && std::floor(first) == first) ||
        root.value("tickMs").toInt() != tickMs || root.value("source").toString() != "synthetic" ||
        root.value("engine").toString() != "local-planar-v1" || !root.value("randomSeed").isNull() ||
        !result.capturedUtc.isValid() || result.capturedUtc.offsetFromUtc() != 0 ||
        !root.value("bookmarks").isArray() || bookmarks.size() > maxBookmarks ||
        !root.value("notes").isString() || result.notes.size() > maxNoteLength)
        return fail("Invalid recording metadata.");
    result.firstTick = static_cast<std::uint64_t>(first);
    for (const auto& value : bookmarks) {
        const auto entry = value.toObject();
        const auto frame = entry.value("frame").toInt(-1);
        const auto label = entry.value("label").toString();
        if (frame < 0 || frame >= frames || label.trimmed().isEmpty() || label.size() > 80)
            return fail("Invalid recording bookmark.");
        result.bookmarks.push_back({frame, label});
    }
    auto scenario = parseScenarioText(result.scenario, error);
    if (!scenario)
        return std::nullopt;
    result.identities = scenario->simulation.aircraft();
    const auto count = static_cast<std::size_t>(frames) * result.identities.size();
    if (count > maxSamples || buffer.bytesAvailable() != static_cast<qint64>(count) * sampleBytes)
        return fail("Recording frame count does not match its payload.");
    result.samples.reserve(count);
    for (std::size_t i = 0; i < count; ++i) {
        Sample sample{};
        stream >> sample.eastKm >> sample.northKm >> sample.altitudeM
               >> sample.eastKmPerSecond >> sample.northKmPerSecond;
        if (!validSample(sample))
            return fail("The recording contains an invalid aircraft sample.");
        result.samples.push_back(sample);
    }
    if (stream.status() != QDataStream::Ok)
        return fail("The recording ended unexpectedly.");
    error.clear();
    return result;
}

} // namespace aeroradar::recording
