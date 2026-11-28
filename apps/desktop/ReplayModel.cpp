#include "ReplayModel.hpp"

#include "TrackView.hpp"

#include <algorithm>
#include <array>
#include <utility>

namespace recording = aeroradar::recording;

ReplayModel::ReplayModel(QObject* parent) : QObject(parent), timer_(this) {
    timer_.setTimerType(Qt::PreciseTimer);
    timer_.setInterval(recording::tickMs);
    connect(&timer_, &QTimer::timeout, this, &ReplayModel::step);
}

bool ReplayModel::recording() const { return recording_; }
bool ReplayModel::available() const { return !recording_ && data_.frameCount() > 0; }
bool ReplayModel::paused() const { return !timer_.isActive(); }
bool ReplayModel::ended() const { return available() && frame_ == lastFrame(); }
int ReplayModel::frame() const { return frame_; }
int ReplayModel::lastFrame() const { return std::max(0, data_.frameCount() - 1); }
double ReplayModel::elapsedSeconds() const {
    return data_.frameCount() == 0 ? 0.0 :
        static_cast<double>(data_.firstTick + frame_) * recording::tickMs / 1000.0;
}
double ReplayModel::rate() const { return rate_; }
QString ReplayModel::notes() const { return data_.notes; }
QString ReplayModel::captureUtc() const { return data_.capturedUtc.toString(Qt::ISODateWithMs); }
QString ReplayModel::error() const { return error_; }

void ReplayModel::setError(QString error) {
    if (error_ != error) {
        error_ = std::move(error);
        emit errorChanged();
    }
}

void ReplayModel::replace(recording::Recording next, bool capturing) {
    timer_.stop();
    data_ = std::move(next);
    recording_ = capturing;
    frame_ = 0;
    selectedId_ = data_.identities.empty() ? std::nullopt : std::optional(data_.identities.front().id);
    setError({});
    emit recordingChanged();
    emit playbackChanged();
    emit tracksChanged();
    emit metadataChanged();
}

void ReplayModel::startCapture(const QString& scenario, std::uint64_t tick,
                               const std::vector<aeroradar::Aircraft>& aircraft) {
    if (recording_ || aircraft.empty())
        return;
    recording::Recording next;
    next.scenario = scenario;
    next.capturedUtc = QDateTime::currentDateTimeUtc();
    next.firstTick = tick;
    next.identities = aircraft;
    next.appendFrame(aircraft);
    replace(std::move(next), true);
}

void ReplayModel::captureTick(std::uint64_t tick, const std::vector<aeroradar::Aircraft>& aircraft) {
    if (!recording_)
        return;
    if (tick != data_.firstTick + static_cast<std::uint64_t>(data_.frameCount())) {
        stopCapture();
        return;
    }
    data_.appendFrame(aircraft);
    if (data_.atCapacity()) {
        stopCapture();
        setError(tr("Recording limit reached. Save the captured recording before starting another."));
    } else {
        emit recordingChanged();
    }
}

void ReplayModel::stopCapture() {
    if (!recording_)
        return;
    recording_ = false;
    emit recordingChanged();
    emit playbackChanged();
    emit tracksChanged();
}

bool ReplayModel::saveRecording(const QUrl& url) {
    if (!available())
        return false;
    QString error;
    const bool saved = recording::save(url, data_, error);
    setError(std::move(error));
    return saved;
}

bool ReplayModel::openRecording(const QUrl& url) {
    if (recording_)
        return false;
    QString error;
    auto loaded = recording::load(url, error);
    if (!loaded) {
        setError(std::move(error));
        return false;
    }
    replace(std::move(*loaded), false);
    return true;
}

void ReplayModel::play() {
    if (available() && paused() && !ended()) {
        timer_.start();
        emit playbackChanged();
    }
}

void ReplayModel::pause() {
    if (!paused()) {
        timer_.stop();
        emit playbackChanged();
    }
}

void ReplayModel::step() { seek(frame_ + 1); }
void ReplayModel::reset() { pause(); seek(0); }

void ReplayModel::seek(int frame) {
    if (!available() || frame < 0 || frame > lastFrame() || frame == frame_)
        return;
    frame_ = frame;
    if (ended())
        timer_.stop();
    emit playbackChanged();
    emit tracksChanged();
}

void ReplayModel::setRate(double rate) {
    constexpr std::array rates{0.25, 0.5, 1.0, 2.0, 4.0};
    if (rate != rate_ && std::ranges::find(rates, rate) != rates.end()) {
        rate_ = rate;
        timer_.setInterval(static_cast<int>(recording::tickMs / rate));
        emit playbackChanged();
    }
}

void ReplayModel::selectTrack(int id) {
    if (selectedId_ == id || std::ranges::find(data_.identities, id, &aeroradar::Aircraft::id) == data_.identities.end())
        return;
    selectedId_ = id;
    emit tracksChanged();
}

QVariantList ReplayModel::tracks() const {
    QVariantList views;
    if (!available())
        return views;
    views.reserve(static_cast<qsizetype>(data_.identities.size()));
    for (std::size_t i = 0; i < data_.identities.size(); ++i) {
        auto aircraft = data_.identities[i];
        const auto sample = data_.sample(frame_, i);
        aircraft.x_km = sample.eastKm;
        aircraft.y_km = sample.northKm;
        aircraft.altitude_m = sample.altitudeM;
        aircraft.vx_km_s = sample.eastKmPerSecond;
        aircraft.vy_km_s = sample.northKmPerSecond;
        QVariantList trail;
        for (int previous = std::max(0, frame_ - 24); previous <= frame_; ++previous) {
            const auto point = data_.sample(previous, i);
            trail.append(QVariantMap{{"x_km", point.eastKm}, {"y_km", point.northKm}});
        }
        views.append(trackView(aircraft, selectedId_ == aircraft.id, std::move(trail)));
    }
    return views;
}

QVariantList ReplayModel::bookmarks() const {
    QVariantList result;
    for (const auto& bookmark : data_.bookmarks)
        result.append(QVariantMap{{"frame", bookmark.frame}, {"label", bookmark.label}});
    return result;
}

bool ReplayModel::addBookmark(const QString& label) {
    const auto normalized = label.trimmed();
    if (!available() || data_.bookmarks.size() >= recording::maxBookmarks ||
        normalized.isEmpty() || normalized.size() > 80)
        return false;
    data_.bookmarks.push_back({frame_, normalized});
    emit metadataChanged();
    return true;
}

void ReplayModel::setNotes(const QString& notes) {
    if (available() && notes.size() <= recording::maxNoteLength && notes != data_.notes) {
        data_.notes = notes;
        emit metadataChanged();
    }
}
