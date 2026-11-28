#include "ScenarioLoader.hpp"

#include <QCoreApplication>
#include <QDir>
#include <QFile>
#include <QFileInfo>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QSaveFile>
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
constexpr qsizetype maxWaypoints = 64;
constexpr double maxPositionKm = 1000.0;
constexpr double maxSpeedKmPerSecond = 2.0;
constexpr double maxRouteTimeS = 86400.0;

bool hasFields(const QJsonObject& object, std::initializer_list<const char*> names,
               qsizetype additionalFields = 0) {
    return object.size() == static_cast<qsizetype>(names.size()) + additionalFields &&
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

double number(const QJsonObject& object, const char* key) {
    return object.value(QLatin1String(key)).toDouble(std::numeric_limits<double>::quiet_NaN());
}

bool validPosition(double east, double north, double altitude) {
    return std::abs(east) <= maxPositionKm && std::abs(north) <= maxPositionKm &&
           altitude >= -500.0 && altitude <= 30000.0;
}

std::optional<aeroradar::Aircraft> parseAircraft(const QJsonObject& object, bool hasWaypoints) {
    using aeroradar::Aircraft;
    using aeroradar::AircraftType;

    if (!hasFields(object, {"id", "label", "type", "x_km", "y_km", "vx_km_s", "vy_km_s", "altitude_m"},
                   hasWaypoints ? 1 : 0))
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

    aircraft.x_km = number(object, "x_km");
    aircraft.y_km = number(object, "y_km");
    aircraft.vx_km_s = number(object, "vx_km_s");
    aircraft.vy_km_s = number(object, "vy_km_s");
    aircraft.altitude_m = number(object, "altitude_m");

    if (!validPosition(aircraft.x_km, aircraft.y_km, aircraft.altitude_m) ||
        !(std::hypot(aircraft.vx_km_s, aircraft.vy_km_s) <= maxSpeedKmPerSecond))
        return std::nullopt;

    return aircraft;
}

std::optional<aeroradar::AircraftRoute> parseRoute(const QJsonValue& input,
                                                  const aeroradar::Aircraft& aircraft) {
    const auto records = input.toArray();
    if (records.isEmpty() || records.size() > maxWaypoints)
        return std::nullopt;

    aeroradar::AircraftRoute route{aircraft.id, {}};
    route.waypoints.reserve(static_cast<std::size_t>(records.size()));
    aeroradar::Waypoint previous{0.0, aircraft.x_km, aircraft.y_km, aircraft.altitude_m};
    for (const auto& record : records) {
        const auto fields = record.toObject();
        if (!hasFields(fields, {"time_s", "x_km", "y_km", "altitude_m"}))
            return std::nullopt;
        const aeroradar::Waypoint point{
            number(fields, "time_s"), number(fields, "x_km"), number(fields, "y_km"),
            number(fields, "altitude_m")
        };
        if (!(point.time_s > previous.time_s && point.time_s <= maxRouteTimeS) ||
            !validPosition(point.x_km, point.y_km, point.altitude_m))
            return std::nullopt;
        const auto duration = point.time_s - previous.time_s;
        if (!(std::hypot(point.x_km - previous.x_km, point.y_km - previous.y_km) /
              duration <= maxSpeedKmPerSecond))
            return std::nullopt;
        route.waypoints.push_back(point);
        previous = point;
    }
    return route;
}

QString message(const char* reason) {
    return QCoreApplication::translate("ScenarioLoader", reason);
}

QString localPath(const QUrl& fileUrl) {
    if (!fileUrl.isLocalFile() || !fileUrl.host().isEmpty())
        return {};
    const auto path = QDir::fromNativeSeparators(fileUrl.toLocalFile());
    if (path.startsWith(QLatin1String("//")) || !QDir::isAbsolutePath(path))
        return {};
    return path;
}

std::optional<LoadedScenario> parseScenario(const QByteArray& contents, QString& error) {
    const auto fail = [&error](const char* reason) -> std::optional<LoadedScenario> {
        error = message(reason);
        return std::nullopt;
    };
    if (contents.size() > maxScenarioBytes)
        return fail("The scenario file exceeds 256 KiB.");

    const auto document = QJsonDocument::fromJson(contents);
    if (!document.isObject())
        return fail("The scenario must be a valid JSON object.");
    const auto root = document.object();
    const int version = root.value("version").toInt();
    if (!hasFields(root, {"format", "version", "source", "name", "aircraft"}) ||
        root.value("format").toString() != QLatin1String("nexvary.aeroradar.scenario") ||
        (version != 1 && version != 2) ||
        root.value("source").toString() != QLatin1String("synthetic"))
        return fail("Use a supported version 1 or 2 synthetic scenario file.");

    const auto name = validatedText(root.value("name"), 80);
    const auto records = root.value("aircraft").toArray();
    if (name.isEmpty() || records.isEmpty() || records.size() > maxAircraft)
        return fail("Use a scenario name and between 1 and 256 aircraft.");

    std::vector<aeroradar::Aircraft> aircraft;
    std::vector<aeroradar::AircraftRoute> routes;
    aircraft.reserve(static_cast<std::size_t>(records.size()));
    for (const auto& record : records) {
        const auto object = record.toObject();
        const bool hasWaypoints = version == 2 && object.contains("waypoints");
        auto parsed = parseAircraft(object, hasWaypoints);
        if (!parsed)
            return fail("A scenario aircraft has invalid fields, type or units.");
        if (hasWaypoints) {
            auto route = parseRoute(object.value("waypoints"), *parsed);
            if (!route)
                return fail("A waypoint route has invalid fields, times or speed.");
            routes.push_back(std::move(*route));
        }
        aircraft.push_back(std::move(*parsed));
    }

    try {
        LoadedScenario loaded{name, QString::fromUtf8(contents), aeroradar::Simulator(std::move(aircraft), std::move(routes))};
        error.clear();
        return loaded;
    } catch (const std::invalid_argument&) {
        return fail("Scenario aircraft must have unique IDs and valid state and routes.");
    }
}

} // namespace

std::optional<LoadedScenario> loadScenarioFile(const QUrl& fileUrl, QString& error) {
    const auto fail = [&error](const char* reason) -> std::optional<LoadedScenario> {
        error = message(reason);
        return std::nullopt;
    };
    const QString path = localPath(fileUrl);
    if (path.isEmpty() || !QFileInfo(path).isFile())
        return fail("The scenario must be a regular local file.");

    QFile file(path);
    if (!file.open(QIODevice::ReadOnly))
        return fail("The scenario file could not be opened.");
    if (file.size() > maxScenarioBytes)
        return fail("The scenario file exceeds 256 KiB.");

    const auto contents = file.read(maxScenarioBytes + 1);
    if (file.error() != QFileDevice::NoError)
        return fail("The scenario file could not be read.");
    return parseScenario(contents, error);
}

std::optional<LoadedScenario> parseScenarioText(const QString& text, QString& error) {
    if (text.size() > maxScenarioBytes) {
        error = message("The scenario file exceeds 256 KiB.");
        return std::nullopt;
    }
    return parseScenario(text.toUtf8(), error);
}

bool saveScenarioFile(const QUrl& fileUrl, const QString& text, QString& error) {
    if (!parseScenarioText(text, error))
        return false;

    const QString path = localPath(fileUrl);
    const QFileInfo destination(path);
    if (path.isEmpty() || destination.isSymLink() ||
        (destination.exists() && !destination.isFile())) {
        error = message("Choose a regular local file for saving.");
        return false;
    }

    const auto bytes = text.toUtf8();
    QSaveFile file(path);
    if (!file.open(QIODevice::WriteOnly) || file.write(bytes) != bytes.size() || !file.commit()) {
        error = message("The scenario could not be saved.");
        return false;
    }
    error.clear();
    return true;
}

QString describeBuiltinScenario(const QString& name, const aeroradar::Simulator& simulator) {
    QJsonArray records;
    for (const auto& aircraft : simulator.aircraft()) {
        const QString type = aircraft.type == aeroradar::AircraftType::FIXED_WING
            ? QStringLiteral("fixed-wing") : QStringLiteral("multirotor");
        records.append(QJsonObject{
            {"id", aircraft.id}, {"label", QString::fromStdString(aircraft.label)}, {"type", type},
            {"x_km", aircraft.x_km}, {"y_km", aircraft.y_km},
            {"vx_km_s", aircraft.vx_km_s}, {"vy_km_s", aircraft.vy_km_s},
            {"altitude_m", aircraft.altitude_m}
        });
    }
    const QJsonObject document{
        {"format", "nexvary.aeroradar.scenario"}, {"version", 1}, {"source", "synthetic"},
        {"name", name}, {"aircraft", records}
    };
    return QString::fromUtf8(QJsonDocument(document).toJson(QJsonDocument::Indented));
}
