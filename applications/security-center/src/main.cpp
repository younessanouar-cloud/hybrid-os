/*
 * HYBRID OS — Security Center (Phase 3 ébauche, doc 06 §2)
 * Règle absolue (doc 06) : chaque valeur affichée provient d'une commande
 * système RÉELLE exécutée par SecurityBridge. Aucune donnée simulée ;
 * les rubriques non câblées sont absentes de l'écran.
 */
#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickStyle>
#include "securitybridge.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    app.setOrganizationName("HYBRID OS Project");
    app.setApplicationName("hybrid-security-center");

    QQuickStyle::setStyle("org.kde.desktop");

    SecurityBridge bridge;

    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty("securityBridge", &bridge);
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreationFailed,
                     &app, []() { QCoreApplication::exit(1); },
                     Qt::QueuedConnection);
    engine.loadFromModule("org.hybridos.securitycenter", "Main");

    // Lance toutes les requêtes réelles dès l'ouverture
    bridge.queryAll();

    return app.exec();
}
