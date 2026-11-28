#include "ScenarioLoader.hpp"

#include <QCoreApplication>
#include <QDir>
#include <QFile>
#include <QFileInfo>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QUrl>
#include <algorithm>
#include <cmath>
#include <initializer_list>
#include <limits>
#include <stdexcept>
#include <utility>

namespace {

constexpr qint64 maxScenarioBytes = 256 * 1024;
constexpr qsizetype maxAircraft = 256;

bool hasFields(const QJsonObject& object, std::initializer_list<const char*> names) {
    return object.size() == static_cast<qsizetype>(names.size()) &&
           std::ranges::all_of(names, [&object](const char* name) {
               return object.contains(QLatin1String(name));
           });
}

QString validatedText(const QJsonValue& value, qsizetype maximum) {
    const auto text = value.toString().trimmed();
    if (text.size() > maximum || std::ranges::any_of(text, [](QChar character) {
            return character.category() == QChar::Other_Control ||
                   character.category() == QChar::Other_Format;
        }))
        return {};
    return text;
}

std::optional<aeroradar::Aircraft> parseAircraft(const QJsonObject& object) {
    using aeroradar::Aircraft;
    using aeroradar::AircraftType;

    if (!hasFields(object, {"id", "label", "type", "x_km", "y_km", "vx_km_s", "vy_km_s", "altitude_m"}))
        return std::nullopt;

    Aircraft aircraft;
    aircraft.id = object.value("id").toInt();
    const auto label = validatedText(object.value("label"), 64);
    if (aircraft.id <= 0 || label.isEmpty())
        return std::nullopt;
    aircraft.label = label.toStdString();

    const auto type = object.value("type").toString();
    if (type == QLatin1String("fixed-wing"))
        aircraft.type = AircraftType::FIXED_WING;
    else if (type == QLatin1String("multirotor"))
        aircraft.type = AircraftType::MULTIROTOR;
    else
        return std::nullopt;

    const auto number = [&object](const char* key) {
        return object.value(QLatin1String(key)).toDouble(std::numeric_limits<double>::quiet_NaN());
    };
    aircraft.x_km = number("x_km");
    aircraft.y_km = number("y_km");
    aircraft.vx_km_s = number("vx_km_s");
    aircraft.vy_km_s = number("vy_km_s");
    aircraft.altitude_m = number("altitude_m");

    // These are file-format bounds, independent of the numerical kernel's limits.
    if (!(std::abs(aircraft.x_km) <= 1000.0 && std::abs(aircraft.y_km) <= 1000.0 &&
          std::hypot(aircraft.vx_km_s, aircraft.vy_km_s) <= 2.0 &&
          aircraft.altitude_m >= -500.0 && aircraft.altitude_m <= 30000.0))
        return std::nullopt;

    return aircraft;
}

} // namespace

std::optional<LoadedScenario> loadScenarioFile(const QUrl& fileUrl, QString& error) {
    const auto fail = [&error](const char* reason) -> std::optional<LoadedScenario> {
        error = QCoreApplication::translate("ScenarioLoader", reason);
        return std::nullopt;
    };
    if (!fileUrl.isLocalFile() || !fileUrl.host().isEmpty())
        return fail("Choose a local scenario file.");

    const QString path = QDir::fromNativeSeparators(fileUrl.toLocalFile());
    const QFileInfo info(path);
    if (path.startsWith(QLatin1String("//")) || !info.isAbsolute() || !info.isFile())
        return fail("The scenario must be a regular local file.");

    QFile file(path);
    if (!file.open(QIODevice::ReadOnly))
        return fail("The scenario file could not be opened.");
    if (file.size() > maxScenarioBytes)
        return fail("The scenario file exceeds 256 KiB.");

    const auto contents = file.read(maxScenarioBytes + 1);
    if (file.error() != QFileDevice::NoError)
        return fail("The scenario file could not be read.");
    if (contents.size() > maxScenarioBytes)
        return fail("The scenario file exceeds 256 KiB.");

    const auto document = QJsonDocument::fromJson(contents);
    if (!document.isObject())
        return fail("The scenario must be a valid JSON object.");
    const auto root = document.object();
    if (!hasFields(root, {"format", "version", "source", "name", "aircraft"}) ||
        root.value("format").toString() != QLatin1String("nexvary.aeroradar.scenario") ||
        root.value("version").toInt() != 1 ||
        root.value("source").toString() != QLatin1String("synthetic"))
        return fail("This file does not match the version 1 synthetic scenario format.");

    const auto name = validatedText(root.value("name"), 80);
    const auto records = root.value("aircraft").toArray();
    if (name.isEmpty() || records.isEmpty() || records.size() > maxAircraft)
        return fail("Use a scenario name and between 1 and 256 aircraft.");

    std::vector<aeroradar::Aircraft> aircraft;
    aircraft.reserve(static_cast<std::size_t>(records.size()));
    for (const auto& record : records) {
        auto parsed = parseAircraft(record.toObject());
        if (!parsed)
            return fail("A scenario aircraft has invalid fields, type or units.");
        aircraft.push_back(std::move(*parsed));
    }

    try {
        LoadedScenario loaded{name, aeroradar::Simulator(std::move(aircraft))};
        error.clear();
        return loaded;
    } catch (const std::invalid_argument&) {
        return fail("Scenario aircraft must have unique IDs and valid state.");
    }
}
