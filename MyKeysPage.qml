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
        onRestored: {
            rpc.refreshAccounts(accountList.toVarArray().map(function(account) { return account.name }))
        }
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
            url: "wss://steemit.com/wspa"
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

        function refreshAccounts(accounts) {
            if (accounts)
                return rpc.call("get_accounts", [accounts]).then(function(accounts) {
                    store.addAccount(accounts[0])
                })
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

        property var accounts: []
        property var accountKey: store.makeKeyPair()
        property string importMode
        property string accountPassword

        onClosed: {
            accounts = []
            accountKey.generateFromSeed("")
            importMode = ""
            accountPassword = ""
            newKeyField.placeholderText = qsTr("Private key or account password")
        }

        function importByPrivateKey() {
            rpc.call("get_key_references", [[accountKey.publicKey]]).then(function(stuff) {
                var accounts = stuff.reduce(function(prev, next) { return prev.concat(next) }, [])
                return rpc.call("get_accounts", [accounts])
            }).then(function(accounts) {
                accounts = accounts.filter(function(account) {
                    return store.accountUnsupportedReason(account) === ""
                })
                if (accounts.length) {
                    addAccountPopup.accounts = accounts
                    var accountsString = ""
                    for (var i = 0; i < accounts.length; ++i)
                        if (accountsString)
                            accountsString += ", " + accounts[i].name
                        else
                            accountsString = accounts[i].name
                    addAccountPopup.infoLabel.text = qsTr("Importing ") + accountsString
                } else {
                    addAccountPopup.infoLabel.text = qsTr("That key doesn't belong to any supported accounts :(")
                }
            })
        }
        function importByPassword() {
            rpc.call("get_accounts", [[addAccountPopup.newKeyField.text]]).then(function(accounts) {
                if (!accounts || accounts.length !== 1) {
                    addAccountPopup.infoLabel.text = qsTr("I can't find an account by that name...")
                    addAccountPopup.accounts = []
                    return
                }
                if (store.accountUnsupportedReason(accounts[0]) !== "") {
                    addAccountPopup.infoLabel.text = qsTr("Sorry, that account isn't supported:\n") +
                            store.accountUnsupportedReason(accounts[0])
                    addAccountPopup.accounts = []
                    return
                }

                var matches = 0
                var check = function(level) {
                    accountKey.generateFromSeed(accounts[0].name + level + accountPassword)
                    if ((accounts[0].hasOwnProperty(level) && accounts[0][level].key_auths[0] === accountKey.publicKey)
                            || accounts[0].memo_key === accountKey.publicKey)
                        ++matches
                }
                check("owner")
                check("active")
                check("posting")
                check("memo")

                if (matches) {
                    addAccountPopup.accounts = accounts
                    addAccountPopup.infoLabel.text = qsTr("Good to go!")
                } else {
                    addAccountPopup.accounts = []
                    addAccountPopup.infoLabel.text = qsTr("The password is incorrect for that account")
                }
            })
        }

        Timer {
            id: accountLookupTimer
            interval: 200
            repeat: false

            onTriggered: {
                if (addAccountPopup.newKeyField.text) {
                    var accountKey = addAccountPopup.accountKey
                    accountKey.fromWifKey(addAccountPopup.newKeyField.text)
                    if (accountKey.keyType !== KeyPair.PrivateKey) {
                        if (addAccountPopup.accountPassword) {
                            return addAccountPopup.importByPassword()
                        }

                        addAccountPopup.infoLabel.text = qsTr("Enter account password above")
                        addAccountPopup.importMode = "password"
                        return
                    }

                    addAccountPopup.infoLabel.text = qsTr("Tis loadin'")
                    addAccountPopup.importMode = "key"
                    addAccountPopup.importByPrivateKey()
                } else {
                    addAccountPopup.infoLabel.text = ""
                }
            }
        }

        newKeyField.onTextChanged: accountLookupTimer.restart()
        acceptButton.enabled: (importMode === "key" && accounts && accounts.length) ||
                              (importMode === "password" && accountPassword === "") ||
                              (importMode === "password" && accounts && accounts.length === 1)
        acceptButton.onClicked: {
            if (importMode === "key") {
                for (var i = 0; i < accounts.length; ++i) {
                    var account = store.addAccount(accounts[i])
                    if (account.ownerKey.equals(accountKey))
                        account.ownerKey.replaceWith(accountKey)
                    if (account.activeKey.equals(accountKey))
                        account.activeKey.replaceWith(accountKey)
                    if (account.postingKey.equals(accountKey))
                        account.postingKey.replaceWith(accountKey)
                    if (account.memoKey.equals(accountKey))
                        account.memoKey.replaceWith(accountKey)
                }

                close()
            } else {
                if (accountPassword) {
                    account = store.addAccount(accounts[0])
                    accountKey.generateFromSeed(account.name + "owner" + accountPassword)
                    if (account.ownerKey.equals(accountKey))
                        account.ownerKey.replaceWith(accountKey)
                    accountKey.generateFromSeed(account.name + "active" + accountPassword)
                    if (account.activeKey.equals(accountKey))
                        account.activeKey.replaceWith(accountKey)
                    accountKey.generateFromSeed(account.name + "posting" + accountPassword)
                    if (account.postingKey.equals(accountKey))
                        account.postingKey.replaceWith(accountKey)
                    accountKey.generateFromSeed(account.name + "memo" + accountPassword)
                    if (account.memoKey.equals(accountKey))
                        account.memoKey.replaceWith(accountKey)

                    close()
                } else {
                    accountPassword = newKeyField.text
                    newKeyField.placeholderText = "Account name"
                    newKeyField.text = ""
                    infoLabel.text = qsTr("Now enter account name above")
                    accountLookupTimer.stop()
                }
            }
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

                // Generate/sign the transaction
                var promise = rpc.call("get_dynamic_global_properties", []).then(function(properties) {
                    var trx = foundry.keyUpdateTransaction(name, authorityLevel, newKey, properties.head_block_id)
                    // Once the transaction is signed, update the key in the GUI. It's important that we sign first, or
                    // else we are liable to update the key we need to sign with and sign with the new key instead of
                    // the one on chain. Derp!
                    key.replaceWith(newKey)
                    return trx
                })
                promise = Q.all([promise, keyUpdateTimer.triggered])
                promise.reject(changeKeySnackbar.cancelClicked)

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
                return rpc.refreshAccounts([name])
            }, function(error) {
                changeKeySnackbar.openWithMessage(qsTr("It didn't work :("), qsTr("Dismiss"))
                console.error("Key update failed:", JSON.stringify(error))
                key.replaceWith(backupKey)
                return rpc.call("get_accounts", [[name]])
            })
        }
    }

    newAccountButton.onClicked: addAccountPopup.open()
    emptyAccountListLabel.onLinkActivated: newAccountButton.clicked()
    deleteAccountButton.onClicked: accountList.model.remove(accountList.currentIndex)
}
