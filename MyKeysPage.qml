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
    property alias keyStore: store

    KeyStore {
        id: store
    }
    TransactionFoundry {
        id: foundry
        keyStore: store
    }

    JsonRpcProvider {
        id: rpc
        property int networkApi
        socket: WebSocket {
            id: socket
            active: true
            url: "wss://steemit.com/wstmp3"
            onStatusChanged: {
                console.log(status, errorString)
                if (status === WebSocket.Error) {
                    active = false
                    active = true
                }
                if (status === WebSocket.Open) {
                    rpc.call("call", [1, "login", ["",""]]).then(function() {
                        rpc.call("call", [1, "get_api_by_name", ["network_broadcast_api"]]).then(function(id) {
                            rpc.networkApi = id
                        })
                    })
                }
            }
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

        function openWithMessage(message, buttonText) {
            changeKeySnackbarLabel.text = message? message : ""
            changeKeySnackbarButton.text = buttonText? buttonText : ""
            keyUpdateTimer.restart()
            open()
        }

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

        signal cancelClicked

        background: Rectangle {
            color: "#323232"
        }

        Timer {
            id: keyUpdateTimer
            interval: 5000
            repeat: false
            onTriggered: changeKeySnackbar.close()
        }
        RowLayout {
            anchors.top: parent.top
            width: parent.width
            spacing: 24

            Label {
                id: changeKeySnackbarLabel
                anchors.verticalCenter: parent.verticalCenter
                Layout.fillWidth: true
                color: "white"
            }

            Button {
                id: changeKeySnackbarButton
                font.bold: true
                anchors.verticalCenter: parent.verticalCenter
                onClicked: {
                    changeKeySnackbar.cancelClicked()
                    keyUpdateTimer.stop()
                    changeKeySnackbar.close()
                }
                background: Item{}
                contentItem: Text { text: changeKeySnackbarButton.text; font: changeKeySnackbarButton.font; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter; color: "white" }
            }
        }
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

        function saveKey(key) {
            if (key.equals(ownerKey))
                ownerKey.replaceWith(key)
            if (key.equals(activeKey))
                activeKey.replaceWith(key)
            if (key.equals(postingKey))
                postingKey.replaceWith(key)
            if (key.equals(memoKey))
                memoKey.replaceWith(key)
        }

        onEditKey: {
            var backupKey = key.deepCopy()
            var page = keysForm.StackView.view.push(Qt.resolvedUrl("EditKeysPage.qml"), {keyPair: key})
            page.modifiedKeyPromise.then(function(newKey) {
                keysForm.StackView.view.pop(keysForm)

                if (newKey.keyType === KeyPair.NullKey) {
                    changeKeySnackbar.openWithMessage(qsTr("I'm sorry, Dave. I'm afraid I can't do that"),
                                                      qsTr("Dismiss"))
                    return "pass"
                }
                if (key.equals(newKey)) {
                    if (key.keyType === KeyPair.PublicKey && newKey.keyType === KeyPair.PrivateKey) {
                        saveKey(newKey)
                        changeKeySnackbar.openWithMessage(qsTr("Private key saved"), qsTr("Dismiss"))
                    } else
                        changeKeySnackbar.openWithMessage(qsTr("Key not changed"), qsTr("Dismiss"))
                    return "pass"
                }

                changeKeySnackbar.openWithMessage(qsTr("Updating key"), qsTr("Cancel"))

                // Generate/sign the transaction now...
                var promise = rpc.call("get_dynamic_global_properties", []).then(function(properties) {
                    return foundry.keyUpdateTransaction(name, authorityLevel, newKey, properties.head_block_id)
                })
                promise = Q.all([promise, keyUpdateTimer.triggered])
                promise.reject(changeKeySnackbar.cancelClicked)

                // So we can replace the key (and update the UI) without losing the ability to sign
                key.replaceWith(newKey)

                return promise.then(function(list) { return list[0] })
            }, function() {
                keysForm.StackView.view.pop(keysForm)
            }).then(function(trx) {
                if (!trx || trx === "pass")
                    return

                changeKeySnackbar.close()
                console.log("Update key", JSON.stringify(trx))
                return rpc.call("call", [rpc.networkApi, "broadcast_transaction_synchronous", [trx]])
            }, function() {
                console.log("Key update canceled")
            }).then(function(confirmation) {
                if (confirmation)
                    console.log(JSON.stringify(confirmation))
                return rpc.call("get_accounts", [[name]])
            }, function(error) {
                changeKeySnackbar.openWithMessage(qsTr("It didn't work :("), qsTr("Dismiss"))
                console.error("Key update failed:", JSON.stringify(error))
                key.replaceWith(backupKey)
                return rpc.call("get_accounts", [[name]])
            }).then(function(accounts) {
                store.addAccount(accounts[0])
            })
        }
    }

    newAccountButton.onClicked: addAccountPopup.open()
    emptyAccountListLabel.onLinkActivated: newAccountButton.clicked()
    deleteAccountButton.onClicked: accountList.model.remove(accountList.currentIndex)
}
