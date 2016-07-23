#ifndef ACCOUNTKEYS_HPP
#define ACCOUNTKEYS_HPP

#include "KeyPair.hpp"

#include <QObject>

class AccountKeys : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString name READ name WRITE setName NOTIFY nameChanged)
    Q_PROPERTY(KeyPair* ownerKey READ ownerKey CONSTANT)
    Q_PROPERTY(KeyPair* activeKey READ activeKey CONSTANT)
    Q_PROPERTY(KeyPair* postingKey READ postingKey CONSTANT)
    Q_PROPERTY(KeyPair* memoKey READ memoKey CONSTANT)

    QString m_name;
    KeyPair* m_ownerKey = new KeyPair(this);
    KeyPair* m_activeKey = new KeyPair(this);
    KeyPair* m_postingKey = new KeyPair(this);
    KeyPair* m_memoKey = new KeyPair(this);

public:
    explicit AccountKeys(QObject *parent = 0);

    QString name() const { return m_name; }
    KeyPair* ownerKey() const { return m_ownerKey; }
    KeyPair* activeKey() const { return m_activeKey; }
    KeyPair* postingKey() const { return m_postingKey; }
    KeyPair* memoKey() const { return m_memoKey; }

signals:
    void nameChanged(QString name);

public slots:
    void setName(QString name);
};

#endif // ACCOUNTKEYS_HPP
