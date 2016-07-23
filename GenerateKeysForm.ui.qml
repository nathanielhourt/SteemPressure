import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.0

Item {
    id: item1
    property alias recoverButton: recoverButton
    property alias seedField: seedField
    property alias publicKeyField: publicKeyField
    property alias privateKeyField: privateKeyField
    property alias generateButton: generateButton
    ColumnLayout {
        id: columnLayout1
        x: 270
        y: 190
        width: 599
        height: 175
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter

        RowLayout {
            id: rowLayout1
            width: 100
            height: 100

            TextField {
                id: seedField
                Layout.fillWidth: true
            }

            Button {
                id: recoverButton
                text: qsTr("Recover")
            }
        }

        Button {
            id: generateButton
            text: qsTr("Generate")
            Layout.fillWidth: true
        }

        TextField {
            id: publicKeyField
            text: qsTr("")
            Layout.fillWidth: true
        }

        TextField {
            id: privateKeyField
            text: qsTr("")
            Layout.fillWidth: true
        }
    }
}
