import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.1
import Qt.WebSockets 1.0
import com.nathanhourt.steem.accounts 1.0
import com.nathanhourt.steem.crypto 1.0
import com.nathanhourt.rpc 1.0

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
                // TODO: update the new key on chain
                keysForm.StackView.view.pop(keysForm)
            }, function() {
                keysForm.StackView.view.pop(keysForm)
            })
        }
    }

    newAccountButton.onClicked: addAccountPopup.open()
    emptyAccountListLabel.onLinkActivated: newAccountButton.clicked()
    deleteAccountButton.onClicked: accountList.model.remove(accountList.currentIndex)
}
