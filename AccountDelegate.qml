import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.1
import Qt.WebSockets 1.0
import com.nathanhourt.steem.accounts 1.0
import com.nathanhourt.steem.crypto 1.0
import com.nathanhourt.rpc 1.0

ItemDelegate {
    onClicked: ListView.view.currentIndex = index

    signal editKey(string authorityLevel, KeyPair key)

    contentItem: Column {
        spacing: 4
        Label {
            font.bold: true
            text: name
        }
        KeyDelegate {
            keyName: qsTr("Owner key")
            key: ownerKey
            width: parent.width
            editButton.onClicked: editKey("owner", ownerKey)
        }
        KeyDelegate {
            keyName: qsTr("Active key")
            key: activeKey
            width: parent.width
            editButton.onClicked: editKey("active", activeKey)
        }
        KeyDelegate {
            keyName: qsTr("Posting key")
            key: postingKey
            width: parent.width
            editButton.onClicked: editKey("posting", postingKey)
        }
        KeyDelegate {
            keyName: qsTr("Memo key")
            key: memoKey
            width: parent.width
            editButton.onClicked: editKey("memo_key", memoKey)
        }
    }
}
