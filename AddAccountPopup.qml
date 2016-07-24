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

    TextField {
        id: accountNameField
        anchors.centerIn: parent
        placeholderText: qsTr("Account name")
        onAccepted: acceptButton.clicked()
    }
}
