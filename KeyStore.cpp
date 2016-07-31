#include "KeyStore.hpp"

#include <QSettings>

#include <fc/crypto/aes.hpp>
#include <fc/io/raw.hpp>

KeyStore::KeyStore(QObject *parent)
    : QObject(parent),
      m_accountList(new QQmlObjectListModel<AccountKeys>(this)){
    connect(m_accountList, &QQmlObjectListModel<AccountKeys>::rowsInserted, this, &KeyStore::persist);
    connect(m_accountList, &QQmlObjectListModel<AccountKeys>::rowsRemoved, this, &KeyStore::persist);
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
        connect(accountKeys, &AccountKeys::updated, this, &KeyStore::persist);
        m_accountList->append(accountKeys);
    }

    accountKeys->setName(account["name"].toString());
    accountKeys->ownerKey()->fromAuthority(account["owner"].toMap());
    accountKeys->activeKey()->fromAuthority(account["active"].toMap());
    accountKeys->postingKey()->fromAuthority(account["posting"].toMap());
    accountKeys->memoKey()->fromPublicKey(account["memo_key"].toString());
}

struct PersistenceData {
    uint64_t magic = 'nate';
    std::map<std::string, std::vector<KeyPair::KeyStore>> accountsAndKeys;
};

void KeyStore::persist() {
    if (m_password.isEmpty())
        return;

    wdump(());
    PersistenceData data;
    std::transform(m_accountList->begin(), m_accountList->end(), std::inserter(data.accountsAndKeys,
                                                                               data.accountsAndKeys.begin()),
                   [](const AccountKeys* account) {
        return std::make_pair(account->name().toStdString(),
                              std::vector<KeyPair::KeyStore>{
                                  account->ownerKey()->keyStore(),
                                  account->activeKey()->keyStore(),
                                  account->postingKey()->keyStore(),
                                  account->memoKey()->keyStore()
                              });
    });

    auto buffer = fc::raw::pack(data);
    buffer = fc::aes_encrypt(fc::sha512::hash(m_password.toStdString()), std::move(buffer));
    if (!hasPersistedData())
        emit hasPersistedDataChanged(true);
    QSettings().setValue("storage", QByteArray::fromRawData(buffer.data(), buffer.size()));
}

void KeyStore::resetPersistence() {
    QSettings().remove("storage");
    emit hasPersistedDataChanged(false);
}

bool KeyStore::hasPersistedData() {
    return QSettings().contains("storage");
}

bool KeyStore::restore() {
    QString passwordBackup;
    try {
        std::swap(m_password, passwordBackup);
        auto storage = QSettings().value("storage");
        if (storage == QVariant())
            return false;
        auto bytes = storage.toByteArray();
        auto buffer = fc::aes_decrypt(fc::sha512::hash(passwordBackup.toStdString()),
                                      std::vector<char>(bytes.begin(), bytes.end()));
        auto data = fc::raw::unpack<PersistenceData>(buffer);
        if (data.magic != 'nate')
            return false;

        for (const auto& account : data.accountsAndKeys) {
            idump((account.first));
            auto accountKeys = new AccountKeys(this);
            m_accountList->append(accountKeys);
            connect(accountKeys, &AccountKeys::updated, this, &KeyStore::persist);
            accountKeys->setName(QString::fromStdString(account.first));
            accountKeys->ownerKey()->fromKeyStore(account.second[0]);
            accountKeys->activeKey()->fromKeyStore(account.second[1]);
            accountKeys->postingKey()->fromKeyStore(account.second[2]);
            accountKeys->memoKey()->fromKeyStore(account.second[3]);
        }

        std::swap(m_password, passwordBackup);
    } catch (fc::exception& e) {
        edump((e));
        return false;
    }

    return true;
}

void KeyStore::setPassword(QString password) {
    if (m_password == password)
        return;

    m_password = password;
    emit passwordChanged(password);
}

FC_REFLECT(PersistenceData, (accountsAndKeys))
