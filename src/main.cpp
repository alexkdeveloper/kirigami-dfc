/*
    SPDX-License-Identifier: GPL-2.0-or-later
    SPDX-FileCopyrightText: %{CURRENT_YEAR} %{AUTHOR} <%{EMAIL}>
*/

#include <QApplication>
#include <QQmlApplicationEngine>
#include <QUrl>
#include <QtQml>
#include <QQmlContext>
#include <QQmlEngine>
#include "about.h"
#include "app.h"
#include "version-dfc.h"
#include <KAboutData>
#include <KLocalizedContext>
#include <KLocalizedString>

#include "qmlEnvironmentVariable.h"
#include "dfcconfig.h"
#include "fileio.h"

Q_DECL_EXPORT int main(int argc, char *argv[])
{
    QGuiApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QApplication app(argc, argv);
    QCoreApplication::setOrganizationName(QStringLiteral("KDE"));
    QCoreApplication::setApplicationName(QStringLiteral("dfc"));

    KAboutData aboutData(
                         // The program name used internally.
                         QStringLiteral("dfc"),
                         // A displayable program name string.
                         i18nc("@title", "Desktop Files Creator"),
                         // The program version string.
                         QStringLiteral("1.0.0"),
                         // Short description of what the app does.
                         i18n("Simple app for creating .desktop files on GNU/Linux"),
                         // The license this code is released under.
                         KAboutLicense::GPL,
                         // Copyright Statement.
                         i18n("(c) 2023"));
    aboutData.addAuthor(i18nc("@info:credit", "Alex K"),
                        i18nc("@info:credit", "Developer"),
                        QStringLiteral("unknown"),
                        QStringLiteral("https://github.com/alexkdeveloper/kirigami-dfc"));
    KAboutData::setApplicationData(aboutData);

    QQmlApplicationEngine engine;

    auto config = dfcConfig::self();

    qmlRegisterSingletonInstance("org.kde.dfc", 1, 0, "Config", config);

    AboutType about;
    qmlRegisterSingletonInstance("org.kde.dfc", 1, 0, "AboutType", &about);

    App application;
    qmlRegisterSingletonInstance("org.kde.dfc", 1, 0, "App", &application);

    qmlRegisterSingletonType<QmlEnvironmentVariable>("QmlEV", 1, 0, "EnvironmentVariable", qmlenvironmentvariable_singletontype_provider);

    engine.rootContext()->setContextObject(new KLocalizedContext(&engine));
    engine.rootContext()->setContextProperty("FileIO", new FileIO());
    engine.load(QUrl(QStringLiteral("qrc:///main.qml")));

    if (engine.rootObjects().isEmpty()) {
        return -1;
    }

    return app.exec();
}
