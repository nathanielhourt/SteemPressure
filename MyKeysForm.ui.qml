import QtQuick 2.4
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3

Item {
    property alias passwordField: passwordField
    property alias accountList: accountList
    property alias newAccountButton: newAccountButton
    property alias deleteAccountButton: deleteAccountButton
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
            width: 400
            height: 160
            Layout.fillHeight: true
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
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
