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

signals:

public slots:
    void addAccount();
};

#endif // KEYSTORE_HPP
