#include "KeyStore.hpp"

KeyStore::KeyStore(QObject *parent)
    : QObject(parent),
      m_accountList(new QQmlObjectListModel<AccountKeys>(this)){

}

void KeyStore::addAccount() {
    m_accountList->append(new AccountKeys(this));
    m_accountList->last()->setName(tr("new-account"));
}
