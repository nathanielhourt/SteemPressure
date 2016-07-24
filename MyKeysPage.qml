import QtQuick 2.7
import QtQuick.Controls 2.0
import com.nathanhourt.steem.accounts 1.0

MyKeysForm {

    KeyStore {
        id: store
    }

    AddAccountPopup {
        id: addAccountPopup
        x: parent.width / 2 - width / 2
        y: parent.height / 2 - height / 2

        acceptButton.onClicked: {
            store.addAccount(accountNameField.text)
            close()
        }
    }

    emptyAccountListPlaceHolder.visible: store.accountList.count === 0
    accountList.model: store.accountList
    accountList.delegate: ItemDelegate {
        highlighted: ListView.isCurrentItem
        width: parent.width
        text: name
        onClicked: ListView.view.currentIndex = index
    }

    newAccountButton.onClicked: addAccountPopup.open()
    emptyAccountListLabel.onLinkActivated: newAccountButton.clicked()
    deleteAccountButton.onClicked: accountList.model.remove(accountList.currentIndex)
}
