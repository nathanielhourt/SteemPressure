#ifndef KEYPAIR_HPP
#define KEYPAIR_HPP

#include <QObject>
#include <QVariantMap>

#include <fc/crypto/elliptic.hpp>
#include <fc/static_variant.hpp>

class KeyPair : public QObject
{
    Q_OBJECT
    Q_PROPERTY(KeyType keyType READ keyType NOTIFY keyTypeChanged)
    Q_PROPERTY(QString publicKey READ publicKey NOTIFY publicKeyChanged)
    Q_PROPERTY(QString wifKey READ wifKey NOTIFY wifKeyChanged)

    // If type is bool, no key is set. Value is irrelevant.
public:
    using KeyStore = fc::static_variant<bool, fc::ecc::public_key, fc::ecc::private_key>;
private:
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
    KeyPair& operator=(const KeyPair& other);
    KeyPair& operator=(KeyPair&& other);

    Q_INVOKABLE void generateFromSeed(QString seed);
    Q_INVOKABLE void generateRandomly();
    Q_INVOKABLE void fromPublicKey(QString publicKey);
    Q_INVOKABLE void fromWifKey(QString wifKey);
    Q_INVOKABLE void fromAuthority(QVariantMap authority);
    void fromKeyStore(KeyStore store) { setKey(store); }

    /// Makes a deep copy of this keypair. Caller takes ownership of returned KeyPair.
    Q_INVOKABLE KeyPair* deepCopy() const { return new KeyPair(*this); }
    /// Overwrites this key with other
    Q_INVOKABLE KeyPair* replaceWith(const KeyPair* other);
    /// Because QML is stupid
    Q_INVOKABLE KeyPair* replaceWith(KeyPair* other) { return replaceWith((const KeyPair*)other); }

    /// Compare this key to other, since javascript doesn't support == operator overloading
    /// @note Returns true if one operand is a public key and the other is a private key, but they are the same key
    Q_INVOKABLE bool equals(const KeyPair* other);
    Q_INVOKABLE bool equals(KeyPair* other) { return equals((const KeyPair*)other); }

    Q_INVOKABLE QString publicKey() const;
    Q_INVOKABLE QString wifKey() const;
    Q_INVOKABLE QVariantMap toAuthority() const;

    fc::ecc::private_key privateKey() const {
        if (keyType() == PrivateKey)
            return key.get<fc::ecc::private_key>();
        return {};
    }
    KeyStore keyStore() const {
        return key;
    }

    KeyType keyType() const;

    static bool isSupportedAuthority(QVariantMap authority);

signals:
    void keyTypeChanged(KeyType);
    void publicKeyChanged(QString);
    void wifKeyChanged(QString);
    void updated();

public slots:
};

#endif // KEYPAIR_HPP
