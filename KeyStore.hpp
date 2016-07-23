#ifndef KEYSTORE_HPP
#define KEYSTORE_HPP

#include <QObject>

class KeyStore : public QObject
{
    Q_OBJECT
public:
    explicit KeyStore(QObject *parent = 0);

signals:

public slots:
};

#endif // KEYSTORE_HPP