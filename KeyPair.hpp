#ifndef KEYPAIR_HPP
#define KEYPAIR_HPP

#include <QObject>

#include <fc/crypto/elliptic.hpp>
#include <fc/static_variant.hpp>

class KeyPair : public QObject
{
    Q_OBJECT
    Q_PROPERTY(KeyType keyType READ keyType NOTIFY keyTypeChanged)
    Q_PROPERTY(QString publicKey READ publicKey NOTIFY publicKeyChanged)
    Q_PROPERTY(QString wifKey READ wifKey NOTIFY wifKeyChanged)

    // If type is bool, no key is set. Value is irrelevant.
    using KeyStore = fc::static_variant<bool, fc::ecc::public_key, fc::ecc::private_key>;
    KeyStore key;
    void setKey(KeyStore newKey);

public:
    enum KeyType {
        NullKey,
        PublicKey,
        PrivateKey
    };
    Q_ENUM(KeyType)

    const static QString KeyPrefix;

    explicit KeyPair(QObject *parent = 0);
    KeyPair(const KeyPair& other) { key = other.key; }
    KeyPair(KeyPair&& other) { key = std::move(other.key); }
    KeyPair& operator=(const KeyPair& other) { key = other.key; return *this; }
    KeyPair& operator=(KeyPair&& other) { key = std::move(other.key); return *this; }

    Q_INVOKABLE void generateFromSeed(QString seed);
    Q_INVOKABLE void generateRandomly();
    Q_INVOKABLE void fromPublicKey(QString publicKey);
    Q_INVOKABLE void fromWifKey(QString wifKey);

    Q_INVOKABLE QString publicKey();
    Q_INVOKABLE QString wifKey();

    KeyType keyType() const;

signals:
    void keyTypeChanged(KeyType);
    void publicKeyChanged(QString);
    void wifKeyChanged(QString);

public slots:
};

#endif // KEYPAIR_HPP
