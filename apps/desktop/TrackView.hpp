#pragma once

#include "aeroradar/Simulator.hpp"
#include <QVariantMap>
#include <utility>

inline QVariantMap trackView(const aeroradar::Aircraft& aircraft, bool selected, QVariantList trail) {
    return {{"id", aircraft.id}, {"label", QString::fromStdString(aircraft.label)},
            {"x_km", aircraft.x_km}, {"y_km", aircraft.y_km}, {"altitude_m", aircraft.altitude_m},
            {"speed_kt", aeroradar::speed_kt(aircraft)}, {"speed_mps", aeroradar::speed_mps(aircraft)},
            {"heading_deg", aeroradar::bearing_deg(aircraft)}, {"range_km", aeroradar::range_km(aircraft)},
            {"type", aircraft.type == aeroradar::AircraftType::MULTIROTOR
                         ? QStringLiteral("UAS") : QStringLiteral("FIXED_WING")},
            {"selected", selected}, {"trail", std::move(trail)}};
}
