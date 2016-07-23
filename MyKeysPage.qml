import QtQuick 2.7
import QtQuick.Controls 2.0
import com.nathanhourt.steem.accounts 1.0

MyKeysForm {
    KeyStore {
        id: store
    }

    accountList.model: store.accountList
    accountList.delegate: ItemDelegate {
        highlighted: ListView.isCurrentItem
        width: parent.width
        text: name
        onClicked: ListView.view.currentIndex = index
    }

    newAccountButton.onClicked: store.addAccount()
}
