#ifndef KEYSTORE_HPP
#define KEYSTORE_HPP

#include "AccountKeys.hpp"

#include <QObject>

#include <QQmlObjectListModel.h>

class KeyStore : public QObject
{
    Q_OBJECT
    QML_OBJMODEL_PROPERTY(AccountKeys, accountList)
    Q_PROPERTY(QString password READ password WRITE setPassword NOTIFY passwordChanged)
    Q_PROPERTY(bool hasPersistedData READ hasPersistedData NOTIFY hasPersistedDataChanged)

    QString m_password;

public:
    explicit KeyStore(QObject *parent = 0);

    /// Determines whether the provided account is supported or not. If unsupported, the human-readable reason is
    /// returned. If supported, the null string is returned.
    Q_INVOKABLE QString accountUnsupportedReason(QVariantMap account);

    Q_INVOKABLE AccountKeys* findAccount(QString accountName);

    Q_INVOKABLE bool hasPersistedData();
    Q_INVOKABLE bool restore();

    QString password() const { return m_password; }

public slots:
    void addAccount(QVariantMap account);
    void persist();
    void resetPersistence();
    void setPassword(QString password);

signals:
    void passwordChanged(QString password);
    void hasPersistedDataChanged(bool);
};



#endif // KEYSTORE_HPP
