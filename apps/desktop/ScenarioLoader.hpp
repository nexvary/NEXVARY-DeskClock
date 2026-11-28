#pragma once

#include "aeroradar/Simulator.hpp"

#include <QString>
#include <optional>

class QUrl;

struct LoadedScenario {
    QString name;
    QString document;
    aeroradar::Simulator simulation;
};

[[nodiscard]] QString describeBuiltinScenario(const QString& name, const aeroradar::Simulator& simulator);
[[nodiscard]] std::optional<LoadedScenario> parseScenarioText(const QString& text, QString& error);
[[nodiscard]] bool saveScenarioFile(const QUrl& fileUrl, const QString& text, QString& error);
[[nodiscard]] std::optional<LoadedScenario> loadScenarioFile(const QUrl& fileUrl, QString& error);
