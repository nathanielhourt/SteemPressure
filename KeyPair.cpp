#include "KeyPair.hpp"

#include <fc/crypto/base58.hpp>
#include <fc/crypto/ripemd160.hpp>
#include <fc/io/raw.hpp>

#include <QDebug>
#include <QCryptographicHash>

const QString KeyPair::KeyPrefix = QStringLiteral("STM");

struct binary_key {
    binary_key() {}
    uint32_t                 check = 0;
    fc::ecc::public_key_data data;
};
FC_REFLECT(binary_key, (data)(check))

void KeyPair::setKey(KeyStore newKey) {
    std::swap(key, newKey);
    if (key.which() != newKey.which())
        emit keyTypeChanged(keyType());
    emit publicKeyChanged(publicKey());
    emit wifKeyChanged(wifKey());
}

KeyPair::KeyPair(QObject *parent)
    : QObject(parent), key(false) {}

KeyPair& KeyPair::operator=(KeyPair&& other) {
    if (this->equals(&other) && other.keyType() != PrivateKey)
        return *this;

    setKey(std::move(other.key));
    return *this;
}

KeyPair& KeyPair::operator=(const KeyPair& other) {
    if (this->equals(&other) && other.keyType() != PrivateKey)
        return *this;

    setKey(other.key);
    return *this;
}

void KeyPair::generateFromSeed(QString seed) {
    setKey(fc::ecc::private_key::regenerate(fc::sha256::hash(seed.toStdString())));
}

void KeyPair::generateRandomly() {
    setKey(fc::ecc::private_key::generate());
}

void KeyPair::fromPublicKey(QString publicKeyString) {
    if (publicKey() == publicKeyString)
        return;

    try {
        if (!publicKeyString.startsWith(KeyPrefix)) {
            qDebug() << "Cannot create KeyPair from public key string due to invalid prefix:" << publicKeyString;
            return setKey(false);
        }

        auto buffer = fc::from_base58(publicKeyString.mid(KeyPrefix.size()).toStdString());
        auto keyData = fc::raw::unpack<binary_key>(buffer);
        if (fc::ripemd160::hash(keyData.data.data, keyData.data.size())._hash[0] != keyData.check) {
            qDebug() << "Cannot create KeyPair from public key string due to invalid checksum" << publicKeyString;
            return setKey(false);
        }

        setKey(fc::ecc::public_key(keyData.data));
    } catch (fc::exception& e) {
        qDebug() << "Cannot create KeyPair from public key string due to exception" << publicKeyString
                 << e.to_detail_string().c_str();
        setKey(false);
    }
}

void KeyPair::fromWifKey(QString wifKey) {
    try {
        auto buffer = fc::from_base58(wifKey.toStdString());
        if (buffer.size() < 5) {
            qDebug() << "Cannot create KeyPair from WIF due to undersized buffer" << buffer.size();
            return setKey(false);
        }
        if (buffer[0] != '\x80') {
            qDebug() << "Cannot create KeyPair from WIF due to invalid prefix" << buffer.size();
            return setKey(false);
        }
        auto easyBuffer = QByteArray::fromRawData(buffer.data(), buffer.size());
        qDebug() << easyBuffer.toHex();
        auto checksum = easyBuffer.right(4);
        easyBuffer.chop(4);

        auto keyHash = QCryptographicHash::hash(easyBuffer, QCryptographicHash::Sha256);
        qDebug() << keyHash.toHex();
        auto reHash = QCryptographicHash::hash(keyHash, QCryptographicHash::Sha256);
        qDebug() << reHash.toHex();

        if (keyHash.left(4) == checksum || reHash.left(4) == checksum) {
            buffer.resize(buffer.size() - 4);
            buffer.erase(buffer.begin());
            return setKey(fc::variant(buffer).as<fc::ecc::private_key>());
        }

        qDebug() << "Cannot create KeyPair from WIF due to invalid checksum";
        setKey(false);
    } catch (fc::exception& e) {
        qDebug() << "Cannot create KeyPair from WIF due to exception" << e.to_detail_string().c_str();
        setKey(false);
    }
}

void KeyPair::fromAuthority(QVariantMap authority) {
    if (!isSupportedAuthority(authority)) {
        qDebug() << "Cannot create KeyPair from unsupported authority" << authority;
        setKey(false);
    }

    auto keyAndWeight = authority["key_auths"].toList().first().toList();
    if (keyAndWeight[1].toInt() < authority["weight_threshold"].toInt())
        setKey(false);
    else
        fromPublicKey(keyAndWeight[0].toString());
}

KeyPair* KeyPair::replaceWith(const KeyPair* other) {
    if (other == nullptr) {
        setKey(false);
        return this;
    }
    *this = *other;
    return this;
}

bool KeyPair::equals(const KeyPair* other) {
    if (keyType() == NullKey && other->keyType() == NullKey)
        return true;
    if (keyType() == NullKey || other->keyType() == NullKey)
        return false;
    return publicKey() == other->publicKey();
}

QString KeyPair::publicKey() const {
    binary_key keyData;
    if (keyType() == PublicKey)
        keyData.data = key.get<fc::ecc::public_key>();
    else if (keyType() == PrivateKey)
        keyData.data = key.get<fc::ecc::private_key>().get_public_key();

    keyData.check = fc::ripemd160::hash(keyData.data.data, keyData.data.size())._hash[0];
    auto buffer = fc::raw::pack(keyData);

    return QString::fromStdString(fc::to_base58(buffer)).prepend(KeyPrefix);
}

QString KeyPair::wifKey() const {
    std::vector<char> buffer(256/8, 0);
    if (keyType() == PrivateKey)
        buffer = fc::variant(key.get<fc::ecc::private_key>()).as<std::vector<char>>();
    else
        return tr("Unset");

    auto easyBuffer = QByteArray::fromRawData(buffer.data(), buffer.size()).prepend('\x80');
    auto checksum = QCryptographicHash::hash(easyBuffer, QCryptographicHash::Sha256);
    checksum = QCryptographicHash::hash(checksum, QCryptographicHash::Sha256).left(4);
    auto wifBuffer = easyBuffer + checksum;

    return QString::fromStdString(fc::to_base58(wifBuffer.data(), wifBuffer.size()));
}

QVariantMap KeyPair::toAuthority() const {
    return {
        {"weight_threshold", 1},
        {"account_auths", QVariantList()},
        {"key_auths", QVariantList {
                QVariantList {publicKey(), 1}
            }
        }
    };
}

KeyPair::KeyType KeyPair::keyType() const {
    if (key.which() == decltype(key)::tag<bool>::value)
        return NullKey;
    if (key.which() == decltype(key)::tag<fc::ecc::public_key>::value)
        return PublicKey;
    return PrivateKey;
}

bool KeyPair::isSupportedAuthority(QVariantMap authority) {
    if (!authority["account_auths"].toList().isEmpty())
        return false;
    if (authority["key_auths"].toList().size() != 1)
        return false;
    return true;
}
