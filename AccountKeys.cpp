#include "AccountKeys.hpp"

AccountKeys::AccountKeys(QObject *parent) : QObject(parent) {

}

void AccountKeys::setName(QString name)
{
    if (m_name == name)
        return;

    m_name = name;
    emit nameChanged(name);
}
