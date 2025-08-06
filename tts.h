#pragma once

#include <memory>

#include <QObject>
#include <QDebug>

#include <QBuffer>
#include <QDataStream>
#include <QAudioFormat>
#include <QAudioSink>
#include <QFile>
#include <QDir>
#include <QStandardPaths>

#include <QEventLoop>

#include <cerevoice_eng.h>

#include "pdf_text_extract/text.h"
// #include <text.h>

class tts : public QObject{
    Q_OBJECT
    Q_PROPERTY(QString userName READ userName WRITE setUserName NOTIFY userNameChanged)

public:
    explicit tts(QObject *parent = nullptr);
    virtual ~tts();
    QString userName();
    void setUserName(const QString &userName);
    Q_INVOKABLE bool echo(const QString &msg) {
        qDebug() << "Called the C++ method with" << msg;
        return true;
    }
    Q_INVOKABLE bool play(const QString &msg, int rateValue);

Q_INVOKABLE bool stop() {
    qDebug()<< "tts_stop";
    int success = CPRCEN_engine_channel_reset(eng, chan);
    player->stop();

    return true;
}

Q_INVOKABLE QString load_pdf() {
    std::string pdfPath = "curious_character.pdf"; // qmake copy to target build location
    // NOTE: the pdf is stored in .file_data/ and is copied to 'assets' directory
    // deployed in apk. At runtime it is extracted and copied to area with permissions
#ifdef Q_OS_ANDROID
    QString appDataLocation = QStandardPaths::writableLocation(QStandardPaths::StandardLocation::AppDataLocation);
    QString pdfPathWithPermissions = appDataLocation + "/curious_character.pdf";

    QFile assetsFile;
    assetsFile.setFileName("assets:/tts_data/curious_character.pdf");
    assetsFile.copy(pdfPathWithPermissions);
    QFile::setPermissions(pdfPathWithPermissions, QFile::WriteOwner | QFile::ReadOwner);

    pdfPath = pdfPathWithPermissions.toStdString();
#endif
    auto textDataPtr = parse_page(pdfPath, 0);
    QString textStr = "";
    if (textDataPtr){
        std::cout << "read result2:"<< textDataPtr->text << std::endl;
        textStr = QString::fromStdString(textDataPtr->text);
    }
    return textStr;
    }

public slots:
    void echo_player(QAudio::State state){
        qDebug() << "echoPlayer " << state;
    }

signals:
    void userNameChanged();
    void quit();

private:
    QString m_userName;
    /// TTS data definitions
    CPRCEN_engine * eng;
    CPRCEN_channel_handle chan;

public:
    std::unique_ptr<QAudioSink> player;
    std::vector<std::unique_ptr<QEventLoop>> event_loop_list; // local loop to block the callback
    bool continue_play=true;
};
