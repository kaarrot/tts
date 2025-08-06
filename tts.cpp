#include "tts.h"

#include <QDataStream>
#include <QAudioSink>

void channel_callback(CPRC_abuf * abuf, void * userdata){

    tts * _tts = (tts *) userdata;
    QAudioSink * player = _tts->player.get();

    // length of the adio in the buffer
    int len = CPRC_abuf_wav_sz(abuf) * 2;
    // pointer to the raw audio data;
    char * wav = (char *) CPRC_abuf_wav_data(abuf);

    qDebug() << "callback---------------";

    QByteArray bytes = QByteArray(wav,len);
    QBuffer *buffer = new QBuffer(&bytes, player);
    buffer->open(QIODevice::ReadWrite);

    // Start player and holds before next callback is triggered
    // The event loop is release with the QAudioOutput::stateChanged signal
    player->start(buffer);
    QEventLoop * last_even_loop = _tts->event_loop_list[_tts->event_loop_list.size()-1].get();
    last_even_loop->exec();
}

Q_INVOKABLE bool tts::play(const QString &msg, int rateValue) {
    chan = CPRCEN_engine_open_default_channel(eng);
    int freq = atoi(CPRCEN_channel_get_voice_info(eng, chan, "SAMPLE_RATE"));
    /// Setting audio params for Qt6
    QAudioFormat fmt = QAudioFormat();
    fmt.setSampleRate(freq);  // 48000
    fmt.setSampleFormat(QAudioFormat::Int16);
    fmt.setChannelCount(1);
    
    // Use default audio output without device detection
    qDebug() << "Creating QAudioSink with format:" << fmt;
    player = std::unique_ptr<QAudioSink>(new QAudioSink(fmt, this));

    event_loop_list.emplace_back(std::unique_ptr<QEventLoop>(new QEventLoop(this)));
    QEventLoop * last_even_loop = event_loop_list[event_loop_list.size()-1].get();

    CPRCEN_engine_set_callback(eng, chan, (void *)this, channel_callback);

    // As we resetting player and callback each time play is pressed - we need to reconnect signals too
    connect(player.get(), &QAudioSink::stateChanged, this, [this, last_even_loop](QAudio::State state) {
        qDebug() << "Audio state changed to:" << state;
        if (state == QAudio::IdleState || state == QAudio::StoppedState) {
            last_even_loop->quit();
        }
    });
    //connect(player,  &QAudioOutput::notify, this, []( ) { qDebug()<<"debugging state changed";} );

    // wrap text prosody tag to control speach rate
    QString msg_rate = QString("<s><prosody rate=\"%1\%\">%2 </prosody></s>").arg(QString::number(rateValue), msg);
    //qDebug() << msg_rate;

    // ignore subsequent play if the former is still playing
    if (player->state() == QAudio::State::ActiveState) return false;

    // reset the channel before playing again
    CPRC_abuf * abuf = CPRCEN_engine_channel_speak(eng, chan, msg_rate.toStdString().c_str(), msg_rate.length(), 1);
    qDebug() << abuf;

    return true;
}

tts::tts(QObject *parent) : QObject(parent){
    /// On start extract file from android assets and place them in the AppDataLocation
    /// C++ libraries can not access files from Qt/android resources directly
#ifdef Q_OS_ANDROID
    QString appDataLocation = QStandardPaths::writableLocation(QStandardPaths::StandardLocation::AppDataLocation);
    QString licAndroidPath = appDataLocation + "/license_eng.lic";
    QString voiceAndroidPath = appDataLocation + "/tts_eng.voice";

    QFile licFile;
    licFile.setFileName("assets:/tts_data/license_eng.lic");
    licFile.copy(licAndroidPath);
    QFile::setPermissions(licAndroidPath, QFile::WriteOwner | QFile::ReadOwner);

    QFile voiceFile;
    voiceFile.setFileName("assets:/tts_data/tts_eng.voice");
    voiceFile.copy(voiceAndroidPath);
    QFile::setPermissions(voiceAndroidPath, QFile::WriteOwner | QFile::ReadOwner);

    eng = CPRCEN_engine_load(licAndroidPath.toStdString().c_str(), voiceAndroidPath.toStdString().c_str());
#endif

#ifdef __linux__
    /// Init voice
    eng = CPRCEN_engine_load("license_eng.lic", "tts_eng.voice");
#endif
    chan = CPRCEN_engine_open_default_channel(eng);
    event_loop_list.emplace_back(std::unique_ptr<QEventLoop>(new QEventLoop(this)));

    // NOTE: All the callbacks and player ar reinitialized in the play method

  }

tts::~tts(){
    CPRCEN_engine_unload_voice(eng, 0);
    CPRCEN_engine_delete(eng);
}

QString tts::userName(){
    return m_userName;
}

void tts::setUserName(const QString &userName){
    if (userName == m_userName) {
        return;
    }

    m_userName = userName;
    emit userNameChanged();
}

/*

<s><prosody volume="+6dB">
I am speaking this at approximately twice the original signal amplitude.
</prosody></s>


<s><prosody rate="80%">
This is spoken at a slower rate.
</prosody></s>

 */
