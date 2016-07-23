import QtQuick 2.7

import com.nathanhourt.steem.crypto 1.0

Page1Form {
    KeyPair {
        id: keyPair
    }

    publicKeyField.text: keyPair.keyType == KeyPair.NullKey? "" : keyPair.publicKey
    publicKeyField.placeholderText: qsTr("Public Key")
    privateKeyField.text: keyPair.keyType == KeyPair.NullKey? "" : keyPair.wifKey
    privateKeyField.placeholderText: qsTr("Private Key")

    seedField.onAccepted: recoverButton.clicked()
    recoverButton.onClicked: keyPair.generateFromSeed(seedField.text)
    generateButton.onClicked: keyPair.generateRandomly()
    publicKeyField.onAccepted: keyPair.fromPublicKey(publicKeyField.text)
    privateKeyField.onAccepted: keyPair.fromWifKey(privateKeyField.text)
}
