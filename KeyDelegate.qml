import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.1
import Qt.WebSockets 1.0
import com.nathanhourt.steem.crypto 1.0
import com.nathanhourt.rpc 1.0

RowLayout {
    property string keyName
    property KeyPair key

    property alias editButton: editButton

    Label {
        text: keyName + ":"
    }
    Label {
        text: key.keyType !== KeyPair.NullKey? key.publicKey : "Unset"
        horizontalAlignment: Label.AlignRight
        elide: Label.ElideMiddle
        Layout.fillWidth: true
    }
    Button {
        id: editButton
        text: qsTr("Edit")
    }
}
