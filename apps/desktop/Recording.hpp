#pragma once

#include "aeroradar/Simulator.hpp"

#include <QDateTime>
#include <QString>
#include <QUrl>

#include <optional>
#include <vector>

namespace aeroradar::recording {

inline constexpr int tickMs = 100;
inline constexpr int maxFrames = 36001;
inline constexpr std::size_t maxSamples = 200000;
inline constexpr int maxBookmarks = 256;
inline constexpr int maxNoteLength = 4096;

struct Sample {
    double eastKm;
    double northKm;
    double altitudeM;
    double eastKmPerSecond;
    double northKmPerSecond;
};

struct Bookmark {
    int frame;
    QString label;
};

struct Recording {
    QString scenario;
    QDateTime capturedUtc;
    std::uint64_t firstTick{};
    std::vector<Aircraft> identities;
    std::vector<Sample> samples;
    std::vector<Bookmark> bookmarks;
    QString notes;

    [[nodiscard]] int frameCount() const;
    [[nodiscard]] bool atCapacity() const;
    void appendFrame(const std::vector<Aircraft>& aircraft);
    [[nodiscard]] Sample sample(int frame, std::size_t track) const;
};

[[nodiscard]] bool save(const QUrl& url, const Recording& recording, QString& error);
[[nodiscard]] std::optional<Recording> load(const QUrl& url, QString& error);

} // namespace aeroradar::recording
