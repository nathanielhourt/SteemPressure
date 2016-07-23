import QtQuick 2.4
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3

Item {
    property alias passwordField: passwordField
    property alias accountList: accountList
    ColumnLayout {
        id: columnLayout1
        anchors.fill: parent

        TextField {
            id: passwordField
            placeholderText: qsTr("Password")
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            echoMode: TextField.Password
        }

        ListView {
            id: accountList
            x: 0
            y: 0
            width: 110
            height: 160
            Layout.fillWidth: false
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            model: ListModel {
                ListElement {
                    name: "Grey"
                    colorCode: "grey"
                }

                ListElement {
                    name: "Red"
                    colorCode: "red"
                }

                ListElement {
                    name: "Blue"
                    colorCode: "blue"
                }

                ListElement {
                    name: "Green"
                    colorCode: "green"
                }
            }
        }
    }
}
