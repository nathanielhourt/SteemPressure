#ifndef TRANSACTIONFOUNDRY_HPP
#define TRANSACTIONFOUNDRY_HPP

#include "KeyStore.hpp"

#include <QObject>

class TransactionFoundry : public QObject {
    Q_OBJECT
    Q_PROPERTY(KeyStore* keyStore READ keyStore WRITE setKeyStore NOTIFY keyStoreChanged)

    KeyStore* m_keyStore;

public:
    explicit TransactionFoundry(QObject *parent = 0);

    Q_INVOKABLE QVariantMap keyUpdateTransaction(QString accountName, QString authorityLevel, KeyPair* newKey, QString referenceBlockId);

    KeyStore* keyStore() const { return m_keyStore; }

public slots:
    void setKeyStore(KeyStore* keyStore);

signals:
    void keyStoreChanged(KeyStore* keyStore);
};

#endif // TRANSACTIONFOUNDRY_HPP
