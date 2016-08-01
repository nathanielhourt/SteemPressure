import QtQuick 2.4
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0

ShadowedPopup {
    onOpened: newKeyField.forceActiveFocus()
    onClosed: newKeyField.text = ""
    acceptButton.text: qsTr("Add Account")
    cancelButton.text: qsTr("Don't Add")

    property alias newKeyField: newKeyField
    property alias infoLabel: infoLabel

    TextField {
        id: newKeyField
        anchors.centerIn: parent
        placeholderText: qsTr("Private key")
        onAccepted: {
            if (acceptButton.enabled)
                acceptButton.clicked()
        }
    }
    Label {
        id: infoLabel
        wrapMode: Label.WrapAtWordBoundaryOrAnywhere
        anchors.top: newKeyField.bottom
        anchors.topMargin: 4
        anchors.left: newKeyField.left
        anchors.right: parent.right
        anchors.rightMargin: 4
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
