import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.1
import Qt.WebSockets 1.0
import com.nathanhourt.steem.accounts 1.0
import com.nathanhourt.steem.crypto 1.0
import com.nathanhourt.rpc 1.0
import QuickPromise 1.0

MyKeysForm {
    id: keysForm

    KeyStore {
        id: store
    }
    JsonRpcProvider {
        id: rpc
        socket: WebSocket {
            id: socket
            active: true
            url: "wss://steemit.com/wstmp3"
            onStatusChanged: console.log(status, errorString)
        }
    }

    Popup {
        id: changeKeySnackbar
        modal: false
        x: 0
        y: ApplicationWindow.window.height - height
        z: 2
        implicitHeight: 48
        implicitWidth: keysForm.width
        margins: 0
        closePolicy: Popup.NoAutoClose

        enter: Transition {
            PropertyAnimation {
                target: changeKeySnackbar
                property: "implicitHeight"
                from: 0; to: 48
                easing.type: Easing.InOutQuad
            }
        }
        exit: Transition {
            PropertyAnimation {
                target: changeKeySnackbar
                property: "implicitHeight"
                from: 48; to: 0
            }
        }

        signal undoClicked

        background: Rectangle {
            color: "#323232"
        }

        RowLayout {
            anchors.top: parent.top
            width: parent.width
            spacing: 24

            Label {
                anchors.verticalCenter: parent.verticalCenter
                Layout.fillWidth: true
                text: qsTr("Key updated")
                color: "white"
            }

            Button {
                id: control
                text: qsTr("Undo")
                font.bold: true
                anchors.verticalCenter: parent.verticalCenter
                onClicked: {
                    changeKeySnackbar.undoClicked()
                    keyUpdateTimer.stop()
                    changeKeySnackbar.close()
                }
                background: Item{}
                contentItem: Text { text: control.text; font: control.font; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter; color: "white" }
            }
        }
    }
    Timer {
        id: keyUpdateTimer
        interval: 5000
        repeat: false
    }

    AddAccountPopup {
        id: addAccountPopup
        x: parent.width / 2 - width / 2
        y: parent.height / 2 - height / 2

        property var account

        Timer {
            id: accountLookupTimer
            interval: 100
            repeat: false

            onTriggered: {
                if (addAccountPopup.accountNameField.text) {
                    addAccountPopup.infoLabel.text = qsTr("Tis loadin'")
                    rpc.call("get_accounts", [[addAccountPopup.accountNameField.text]]).then(function(accounts) {
                        if (accounts.length) {
                            var unsupportedReason = store.accountUnsupportedReason(accounts[0])
                            if (unsupportedReason) {
                                addAccountPopup.infoLabel.text = qsTr("I don't support this kind of account yet:\n") +
                                        unsupportedReason
                                return
                            }
                            addAccountPopup.account = accounts[0]
                            addAccountPopup.infoLabel.text = qsTr("Good to go!")
                        } else {
                            addAccountPopup.infoLabel.text = qsTr("That account doesn't exist :(")
                        }
                    })
                } else {
                    addAccountPopup.infoLabel.text = ""
                }
            }
        }

        accountNameField.onTextChanged: accountLookupTimer.restart()
        acceptButton.enabled: typeof(account) === "object" && account.name === accountNameField.text
        acceptButton.onClicked: {
            store.addAccount(account)
            close()
        }
        cancelButton.onClicked: close()
    }

    emptyAccountListPlaceHolder.visible: store.accountList.count === 0
    accountList.model: store.accountList
    accountList.delegate: AccountDelegate {
        highlighted: ListView.isCurrentItem
        width: parent.width

        onEditKey: {
            var page = keysForm.StackView.view.push(Qt.resolvedUrl("EditKeysPage.qml"), {keyPair: key})
            page.modifiedKeyPromise.then(function(newKey) {
                keyUpdateTimer.restart()
                changeKeySnackbar.open()
                keysForm.StackView.view.pop(keysForm)

                var promise = Q.promise()
                promise.resolve(keyUpdateTimer.triggered)
                promise.reject(changeKeySnackbar.undoClicked)

                return promise.then(function() { return newKey })
            }, function() {
                keysForm.StackView.view.pop(keysForm)
            }).then(function(newKey) {
                changeKeySnackbar.close()
                console.log("Update key from", key.publicKey, "to", newKey.publicKey)
            }, function() {
                console.log("Key update canceled")
            })
        }
    }

    newAccountButton.onClicked: addAccountPopup.open()
    emptyAccountListLabel.onLinkActivated: newAccountButton.clicked()
    deleteAccountButton.onClicked: accountList.model.remove(accountList.currentIndex)
}
