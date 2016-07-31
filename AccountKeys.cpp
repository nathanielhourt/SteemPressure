#include "AccountKeys.hpp"

AccountKeys::AccountKeys(QObject *parent) : QObject(parent) {
    connect(this, &AccountKeys::nameChanged, this, &AccountKeys::updated);
    connect(m_ownerKey, &KeyPair::updated, this, &AccountKeys::updated);
    connect(m_activeKey, &KeyPair::updated, this, &AccountKeys::updated);
    connect(m_postingKey, &KeyPair::updated, this, &AccountKeys::updated);
    connect(m_memoKey, &KeyPair::updated, this, &AccountKeys::updated);
}

void AccountKeys::setName(QString name)
{
    if (m_name == name)
        return;

    m_name = name;
    emit nameChanged(name);
}
