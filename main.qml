import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.0

ApplicationWindow {
    id: window
    visible: true
    width: 640
    height: 480
    title: qsTr("Steem Pressure")

    ShadowedPopup {
        id: passwordEntry
        modal: true
        dim: true
        width: 400
        height: 300
        x: window.width / 2 - width / 2
        y: window.height / 2 - height / 2
        visible: true
        showButtons: false
        closePolicy: Popup.NoAutoClose

        Column {
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width
            spacing: 8

            Label {
                id: welcomeLabel
                text: keysPage.keyStore.hasPersistedData? qsTr("Welcome back! Enter your password to continue")
                                                        : qsTr("Welcome to <b>Steem Pressure</b>! Set a password " +
                                                               "below")

            }
            RowLayout {
                width: parent.width

                TextField {
                    id: passwordTextField
                    placeholderText: qsTr("Enter password here")
                    echoMode: showPasswordButton.pressed? TextField.Normal : TextField.Password
                    Layout.fillWidth: true
                    onAccepted: {
                        keysPage.keyStore.password = text
                        if (keysPage.keyStore.hasPersistedData) {
                            if (keysPage.keyStore.restore())
                                passwordEntry.close()
                            else {
                                passwordLabel.text = qsTr("That password's no good. Try again?")
                                keysPage.keyStore.password = ""
                            }
                        } else {
                            keysPage.keyStore.persist()
                            passwordEntry.close()
                        }
                    }
                    Component.onCompleted: forceActiveFocus()
                }
                Button {
                    id: showPasswordButton
                    text: qsTr("Reveal")
                    onReleased: passwordTextField.forceActiveFocus()
                    onDoubleClicked: {
                        if (passwordTextField.text === "I want to reset all my data") {
                            keysPage.keyStore.resetPersistence()
                            passwordTextField.text = ""
                        }
                    }
                }
            }
            Label {
                id: passwordLabel
                text: qsTr("This password is used to encrypt your keys")
            }
        }
    }

    StackView {
        id: mainStack
        anchors.fill: parent

        initialItem: MyKeysPage {
            id: keysPage
        }
    }
}
