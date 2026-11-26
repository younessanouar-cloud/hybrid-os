/*
 * HYBRID OS — SecurityBridge : passerelle vers les VRAIES sources système
 * (doc 06 §2). Chaque clé = une commande réelle en LECTURE seule.
 * Signal ready(clé, valeur) → l'UI affiche le résultat réel.
 */
#ifndef SECURITYBRIDGE_H
#define SECURITYBRIDGE_H

#include <QObject>
#include <QProcess>

class SecurityBridge : public QObject
{
    Q_OBJECT
public:
    explicit SecurityBridge(QObject *parent = nullptr);

    // Lancé au démarrage de l'application : interroge toutes les sources
    Q_INVOKABLE void queryAll();

signals:
    void ready(const QString &key, const QString &value, bool ok);

private:
    void query(const QString &key, const QString &program,
               const QStringList &args);
    static QString mapKeyToTitle(const QString &key);

    QHash<QString, QProcess *> m_processes;
};

#endif // SECURITYBRIDGE_H
