import QtQuick 2.4
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0

Item {
    property alias passwordField: passwordField
    property alias accountList: accountList
    property alias newAccountButton: newAccountButton
    property alias deleteAccountButton: deleteAccountButton
    property alias emptyAccountListLabel: emptyAccountListLabel
    property alias emptyAccountListPlaceHolder: emptyAccountListPlaceHolder
    ColumnLayout {
        id: columnLayout1
        anchors.rightMargin: 20
        anchors.leftMargin: 20
        anchors.bottomMargin: 20
        anchors.topMargin: 20
        anchors.fill: parent

        TextField {
            id: passwordField
            placeholderText: qsTr("Password")
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            echoMode: TextField.Password
        }

        ListView {
            id: accountList
            width: 400
            height: 160
            Layout.fillHeight: true
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter

            FadeOnVisible {
                id: emptyAccountListPlaceHolder
                anchors.fill: parent

                Image {
                    id: image1
                    opacity: .1
                    sourceSize.height: 100
                    height: 100
                    width: 100
                    anchors.centerIn: parent
                    source: "qrc:/res/steem.svg"
                    fillMode: Image.PreserveAspectFit
                    smooth: true
                    layer.enabled: true
                    layer.effect: Colorize {
                        saturation: 0
                    }
                }
                Label {
                    id: emptyAccountListLabel
                    text: qsTr("No accounts yet... <a href='add'>Add one</a>!")
                    anchors.centerIn: parent
                }
            }
        }

        RowLayout {
            id: rowLayout1
            width: 100
            height: 100
            spacing: 20
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter

            Button {
                id: newAccountButton
                text: qsTr("New Account")
            }

            Button {
                id: deleteAccountButton
                text: qsTr("Delete Account")
            }
        }
    }
}
