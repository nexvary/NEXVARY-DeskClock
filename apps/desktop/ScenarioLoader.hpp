#pragma once

#include "aeroradar/Simulator.hpp"

#include <QString>
#include <optional>

class QUrl;

struct LoadedScenario {
    QString name;
    aeroradar::Simulator simulation;
};

[[nodiscard]] std::optional<LoadedScenario> loadScenarioFile(const QUrl& fileUrl, QString& error);
