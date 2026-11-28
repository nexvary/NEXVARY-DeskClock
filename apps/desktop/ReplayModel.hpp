#pragma once

#include "Recording.hpp"
#include <QObject>
#include <QTimer>
#include <QVariantList>

class ReplayModel : public QObject {
    Q_OBJECT
    Q_PROPERTY(bool recording READ recording NOTIFY recordingChanged)
    Q_PROPERTY(bool available READ available NOTIFY recordingChanged)
    Q_PROPERTY(bool paused READ paused NOTIFY playbackChanged)
    Q_PROPERTY(bool ended READ ended NOTIFY playbackChanged)
    Q_PROPERTY(int frame READ frame NOTIFY playbackChanged)
    Q_PROPERTY(int lastFrame READ lastFrame NOTIFY recordingChanged)
    Q_PROPERTY(double elapsedSeconds READ elapsedSeconds NOTIFY playbackChanged)
    Q_PROPERTY(double rate READ rate NOTIFY playbackChanged)
    Q_PROPERTY(QVariantList tracks READ tracks NOTIFY tracksChanged)
    Q_PROPERTY(QVariantList bookmarks READ bookmarks NOTIFY metadataChanged)
    Q_PROPERTY(QString notes READ notes NOTIFY metadataChanged)
    Q_PROPERTY(QString captureUtc READ captureUtc NOTIFY recordingChanged)
    Q_PROPERTY(QString error READ error NOTIFY errorChanged)

public:
    explicit ReplayModel(QObject* parent = nullptr);

    void startCapture(const QString& scenario, std::uint64_t tick,
                      const std::vector<aeroradar::Aircraft>& aircraft);
    void captureTick(std::uint64_t tick, const std::vector<aeroradar::Aircraft>& aircraft);

    [[nodiscard]] bool recording() const;
    [[nodiscard]] bool available() const;
    [[nodiscard]] bool paused() const;
    [[nodiscard]] bool ended() const;
    [[nodiscard]] int frame() const;
    [[nodiscard]] int lastFrame() const;
    [[nodiscard]] double elapsedSeconds() const;
    [[nodiscard]] double rate() const;
    [[nodiscard]] QVariantList tracks() const;
    [[nodiscard]] QVariantList bookmarks() const;
    [[nodiscard]] QString notes() const;
    [[nodiscard]] QString captureUtc() const;
    [[nodiscard]] QString error() const;

    Q_INVOKABLE void stopCapture();
    Q_INVOKABLE bool saveRecording(const QUrl& url);
    Q_INVOKABLE bool openRecording(const QUrl& url);
    Q_INVOKABLE void play();
    Q_INVOKABLE void pause();
    Q_INVOKABLE void step();
    Q_INVOKABLE void seek(int frame);
    Q_INVOKABLE void reset();
    Q_INVOKABLE void setRate(double rate);
    Q_INVOKABLE void selectTrack(int id);
    Q_INVOKABLE bool addBookmark(const QString& label);
    Q_INVOKABLE void setNotes(const QString& notes);

signals:
    void recordingChanged();
    void playbackChanged();
    void tracksChanged();
    void metadataChanged();
    void errorChanged();

private:
    void replace(aeroradar::recording::Recording next, bool capturing);
    void setError(QString error);

    aeroradar::recording::Recording data_;
    QTimer timer_;
    bool recording_{};
    int frame_{};
    double rate_{1.0};
    std::optional<int> selectedId_;
    QString error_;
};
