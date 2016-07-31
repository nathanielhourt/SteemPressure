#include "KeyStore.hpp"

KeyStore::KeyStore(QObject *parent)
    : QObject(parent),
      m_accountList(new QQmlObjectListModel<AccountKeys>(this)){

}

QString KeyStore::accountUnsupportedReason(QVariantMap account) {
    if (!(account.contains("name") && account.contains("owner") && account.contains("active") &&
          account.contains("posting") && account.contains("memo_key")))
        return tr("Account is malformed");
    if (account["name"].toString().isEmpty())
        return tr("Account has no name");
    if (!(KeyPair::isSupportedAuthority(account["owner"].toMap()) &&
          KeyPair::isSupportedAuthority(account["active"].toMap()) &&
          KeyPair::isSupportedAuthority(account["posting"].toMap())))
        return tr("Account contains multisig authorities");
    return QString::null;
}

AccountKeys* KeyStore::findAccount(QString accountName) {
    auto itr = std::find_if(m_accountList->begin(), m_accountList->end(), [accountName](const AccountKeys* keys) {
        return keys->name() == accountName;
    });

    if (itr == m_accountList->end())
        return nullptr;
    return *itr;
}

void KeyStore::addAccount(QVariantMap account) {
    if (!accountUnsupportedReason(account).isEmpty())
        return;

    AccountKeys* accountKeys(findAccount(account["name"].toString()));
    if (accountKeys == nullptr) {
        accountKeys = new AccountKeys(this);
        m_accountList->append(accountKeys);
    }

    accountKeys->setName(account["name"].toString());
    accountKeys->ownerKey()->fromAuthority(account["owner"].toMap());
    accountKeys->activeKey()->fromAuthority(account["active"].toMap());
    accountKeys->postingKey()->fromAuthority(account["posting"].toMap());
    accountKeys->memoKey()->fromPublicKey(account["memo_key"].toString());
}
