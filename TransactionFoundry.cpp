#include "TransactionFoundry.hpp"
#include "AccountKeys.hpp"

#include <steemit/chain/protocol/transaction.hpp>
#include <steemit/chain/protocol/steem_operations.hpp>
#include <steemit/chain/config.hpp>

#include <fc/io/json.hpp>
#include <fc/crypto/elliptic.hpp>

#include <QJsonDocument>

TransactionFoundry::TransactionFoundry(QObject *parent) : QObject(parent) {
}

QVariantMap TransactionFoundry::keyUpdateTransaction(QString accountName, QString authorityLevel,
                                                     KeyPair* newKey, QString referenceBlockId) {
    if (m_keyStore == nullptr || newKey == nullptr)
        return {};
    auto account = m_keyStore->findAccount(accountName);
    fc::ecc::private_key signingKey;
    if (authorityLevel == "owner")
        signingKey = account->ownerKey()->privateKey();
    else
        signingKey = account->activeKey()->privateKey();
    if (account == nullptr || signingKey == fc::ecc::private_key())
       return {};

    namespace sch = steemit::chain;
    sch::account_update_operation op;
    op.account = accountName.toStdString();

    auto makeAuth = [](KeyPair* k) {
        using fc::json;
        return json::from_string(QJsonDocument::fromVariant(k->toAuthority()).toJson().data()).as<sch::authority>();
    };

    if (authorityLevel == "owner")
        op.owner = makeAuth(newKey);
    else if (authorityLevel == "active")
        op.active = makeAuth(newKey);
    else if (authorityLevel == "posting")
        op.posting = makeAuth(newKey);
    else if (authorityLevel == "memo_key")
        op.memo_key = sch::public_key_type(newKey->publicKey().toStdString());
    else return {};

    steemit::chain::signed_transaction trx;
    trx.operations = {op};
    trx.set_expiration(fc::time_point::now() + fc::minutes(1));
    trx.set_reference_block(sch::block_id_type(referenceBlockId.toStdString()));
    trx.sign(signingKey, STEEMIT_CHAIN_ID);

    return QJsonDocument::fromJson(fc::json::to_string(trx).c_str()).toVariant().toMap();
}

void TransactionFoundry::setKeyStore(KeyStore* keyStore) {
    if (m_keyStore == keyStore)
        return;

    m_keyStore = keyStore;
    emit keyStoreChanged(keyStore);
}
