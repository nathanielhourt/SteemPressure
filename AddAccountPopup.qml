import QtQuick 2.4
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0

Popup {
    id: addAccountPopup
    width: 375
    height: 200
    background: Rectangle {
        layer.enabled: true
        layer.effect: DropShadow {
            color: "#77000000"
            transparentBorder: true
            radius: 50
            samples: 1 + radius * 2
            verticalOffset: 10
        }
    }
    modal: true
    dim: false
    z: 3

    property alias cancelButton: cancelButton
    property alias addButton: addButton
    property alias accountNameField: accountNameField

    onOpened: accountNameField.forceActiveFocus()
    onClosed: accountNameField.text = ""

    ColumnLayout {
        anchors.fill: parent

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            TextField {
                id: accountNameField
                anchors.centerIn: parent
                placeholderText: qsTr("Account name")
                onAccepted: addButton.clicked()
            }
        }
        Row {
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            spacing: 10

            Button {
                id: cancelButton
                text: qsTr("Don't Add")
            }
            Button {
                id: addButton
                text: qsTr("Add Account")
            }
        }
    }
}
