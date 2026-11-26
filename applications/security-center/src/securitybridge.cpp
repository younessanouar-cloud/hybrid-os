/*
 * HYBRID OS — SecurityBridge : exécution réelle des commandes d'état.
 * Commandes en LECTURE seule uniquement (doc 06 : aucune modification).
 */
#include "securitybridge.h"
#include <QTimer>

SecurityBridge::SecurityBridge(QObject *parent) : QObject(parent) {}

void SecurityBridge::query(const QString &key, const QString &program,
                           const QStringList &args)
{
    auto *proc = new QProcess(this);
    m_processes.insert(key, proc);

    connect(proc, &QProcess::finished, this,
            [this, key, proc](int code, QProcess::ExitStatus status) {
                const bool ok = (code == 0 && status == QProcess::NormalExit);
                QString out = QString::fromUtf8(proc->readAllStandardOutput())
                                  .split('\n').first().trimmed();
                if (!ok) {
                    out = QString::fromUtf8(proc->readAllStandardError())
                              .split('\n').first().trimmed();
                }
                emit ready(key, ok ? out : QString(), ok);
                m_processes.remove(key);
                proc->deleteLater();
            });

    connect(proc, &QProcess::errorOccurred, this,
            [this, key, proc](QProcess::ProcessError) {
                emit ready(key, QString(), false);
                m_processes.remove(key);
                proc->deleteLater();
            });

    proc->start(program, args);
}

void SecurityBridge::queryAll()
{
    // --- Sources RÉELLES (doc 06 §2) — lecture seule ---
    // SELinux : mode courant (Enforcing attendu)
    query("selinux", "getenforce", {});
    // Pare-feu firewalld : état du service
    query("firewall", "firewall-cmd", {"--state"});
    // Secure Boot : état rapporté par mokutil (ligne directe, lecture seule)
    query("secureboot", "mokutil", {"--sb-state"});
    // Noyau en cours d'exécution
    query("kernel", "uname", {"-r"});
    // Version du système
    query("release", "cat", {"/etc/fedora-release"});
}

QString SecurityBridge::mapKeyToTitle(const QString &key)
{
    if (key == "selinux")     return "SELinux";
    if (key == "firewall")    return "Pare-feu";
    if (key == "secureboot")  return "Secure Boot";
    if (key == "kernel")      return "Noyau";
    if (key == "release")     return "Système";
    return key;
}
