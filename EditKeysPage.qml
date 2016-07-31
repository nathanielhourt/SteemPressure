import QtQuick 2.7
import com.nathanhourt.steem.crypto 1.0
import QuickPromise 1.0

EditKeysForm {
    property KeyPair keyPair
    property KeyPair modifiedKeypair
    property alias modifiedKeyPromise: modifiedKeyPromise

    Component.onCompleted: modifiedKeypair = keyPair.deepCopy()

    Promise {
        id: modifiedKeyPromise
    }

    Keys.onEscapePressed: modifiedKeyPromise.reject()

    seedField.placeholderText: qsTr("Key recovery phrase")
    publicKeyField.text: modifiedKeypair.keyType === KeyPair.NullKey? "" : modifiedKeypair.publicKey
    publicKeyField.placeholderText: qsTr("Public Key")
    privateKeyField.text: modifiedKeypair.keyType === KeyPair.NullKey? "" : modifiedKeypair.wifKey
    privateKeyField.placeholderText: qsTr("Private Key")

    seedField.onAccepted: recoverButton.clicked()
    recoverButton.onClicked: modifiedKeypair.generateFromSeed(seedField.text)
    generateButton.onClicked: modifiedKeypair.generateRandomly()
    publicKeyField.onAccepted: modifiedKeypair.fromPublicKey(publicKeyField.text)
    privateKeyField.onAccepted: modifiedKeypair.fromWifKey(privateKeyField.text)

    cancelButton.onClicked: modifiedKeyPromise.reject()
    saveButton.onClicked: {
        if (privateKeyField.text !== modifiedKeypair.wifKey)
            privateKeyField.accepted()
        else if (publicKeyField.text !== modifiedKeypair.publicKey)
            publicKeyField.accepted()

        modifiedKeyPromise.resolve(modifiedKeypair)
    }
}
