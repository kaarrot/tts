import QtQuick 2.9
import QtQuick.Controls 2.2
import QtMultimedia 5.0

import custom.tts 1.0
import QtQuick.Window 2.10

ApplicationWindow {
    id: applicationWindow
    visible: true
    width: 300
    height: 480
    title: qsTr("Tabs")

    TTS {
        id: tts
    }

    Flickable
    {
        id: flickable
        anchors.fill: parent
        flickableDirection: Flickable.VerticalFlick
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.left: parent.left
        anchors.leftMargin: 0
        anchors.top: parent.top
        anchors.topMargin: 40

        // place a TextArea inside the flickable, you can edit text
        // but you cannot select because click & move mouse flicks the view.
        TextArea.flickable: TextArea
        {
            id: textarea
            wrapMode: TextArea.Wrap
            font.pointSize: 12
            textMargin: 12

            // textFormat: TextEdit.RichText
            // can select but kills scrolling
            //selectByMouse: true
            text: qsTr("The puquios are an old system of subterranean aqueducts near the city of Nazca, Peru. Out of 36 puquios, most are still functioning and even relied upon to bring fresh water into the arid desert. The puquios have never been fully mapped, nor have any been excavated.")

            // try out links
            //onLinkActivated: Qt.openUrlExternally(link)

            function text_to_read(){
                var pos = textarea.cursorPosition;;
                while (pos > 0) {
                    var text = textarea.getText(pos-1,pos);
                    console.log(text);
                    if (text == " ") break;
                    pos = pos -1;
                }
                var text_tts = getText(pos, textarea.length);
                return text_tts
              }
        }
        ScrollBar.vertical: ScrollBar { }
    }

        Button {
            id: play
            width: 60
            height: 40
            text: qsTr("Play")
            anchors.left: textarea.left
            anchors.leftMargin: 0
            onPressed: {
                console.log(textarea.text_to_read())
                tts.play(textarea.text_to_read(), rate.value)
            }
        }

        Button {
            id: pdf
            width: 60
            height: 40
            text: qsTr("PDF")
            anchors.left: play.right
            anchors.leftMargin: 0
            onPressed: {
                var pdf_text = tts.load_pdf();
                console.log(pdf_text)
                textarea.clear();
                textarea.text = pdf_text
            }
        }

        Button {
            id: stop
            width: 60
            height: 40
            text: qsTr("Stop")
            anchors.left: pdf.right
            anchors.leftMargin: 0
            onPressed: {
                tts.stop();
            }
        }

        SpinBox {
            id: rate
            width: 120
            anchors.verticalCenter: stop.verticalCenter
            anchors.left: stop.right
            anchors.leftMargin: 0
            editable: true
            from: 70
            to: 120
            value: 100
        }
}

