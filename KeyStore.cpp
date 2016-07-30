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

void KeyStore::addAccount(QVariantMap account) {
    if (!accountUnsupportedReason(account).isEmpty())
        return;

    auto accountKeys = std::unique_ptr<AccountKeys>(new AccountKeys(this));
    accountKeys->setName(account["name"].toString());
    accountKeys->ownerKey()->fromAuthority(account["owner"].toMap());
    accountKeys->activeKey()->fromAuthority(account["active"].toMap());
    accountKeys->postingKey()->fromAuthority(account["posting"].toMap());
    accountKeys->memoKey()->fromPublicKey(account["memo_key"].toString());
    m_accountList->append(accountKeys.release());
}
