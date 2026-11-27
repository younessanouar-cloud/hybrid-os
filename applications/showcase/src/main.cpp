/*
 * HYBRID OS — OPALE Showcase (Phase 2)
 * Galerie des composants du design system : palette + OpaleButton +
 * OpaleCard. Sert aussi de test visuel manuel de libopale sur un écran
 * réel (Phase 5). Aucune donnée système — c'est une démonstration
 * graphique assumée (règle §12 : pas de fausses données d'état).
 */
#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQuickStyle>

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    app.setOrganizationName("HYBRID OS Project");
    app.setApplicationName("hybrid-showcase");

    QQuickStyle::setStyle("org.kde.desktop");

    QQmlApplicationEngine engine;
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreationFailed,
                     &app, []() { QCoreApplication::exit(1); },
                     Qt::QueuedConnection);
    engine.loadFromModule("org.hybridos.showcase", "Main");
    return app.exec();
}
