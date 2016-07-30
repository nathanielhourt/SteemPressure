import QtQuick 2.4
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0

ShadowedPopup {
    onOpened: accountNameField.forceActiveFocus()
    onClosed: accountNameField.text = ""
    acceptButton.text: qsTr("Add Account")
    cancelButton.text: qsTr("Don't Add")

    property alias accountNameField: accountNameField
    property alias infoLabel: infoLabel

    TextField {
        id: accountNameField
        anchors.centerIn: parent
        placeholderText: qsTr("Account name")
        onAccepted: {
            if (acceptButton.enabled)
                acceptButton.clicked()
        }
    }
    Label {
        id: infoLabel
        anchors.top: accountNameField.bottom
        anchors.topMargin: 4
        anchors.left: accountNameField.left
        Behavior on text {
            SequentialAnimation {
                PropertyAnimation {
                    target: infoLabel
                    property: "opacity"
                    from: 1; to: 0
                    duration: 100
                }
                PropertyAction { target: infoLabel; property: "text" }
                PropertyAnimation {
                    target: infoLabel
                    property: "opacity"
                    from: 0; to: 1
                    duration: 100
                }
            }
        }
    }
}
