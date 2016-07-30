#ifndef KEYSTORE_HPP
#define KEYSTORE_HPP

#include "AccountKeys.hpp"

#include <QObject>

#include <QQmlObjectListModel.h>

class KeyStore : public QObject
{
    Q_OBJECT
    QML_OBJMODEL_PROPERTY(AccountKeys, accountList)
public:
    explicit KeyStore(QObject *parent = 0);

    /// Determines whether the provided account is supported or not. If unsupported, the human-readable reason is
    /// returned. If supported, the null string is returned.
    Q_INVOKABLE QString accountUnsupportedReason(QVariantMap account);

signals:

public slots:
    void addAccount(QVariantMap account);
};

#endif // KEYSTORE_HPP
