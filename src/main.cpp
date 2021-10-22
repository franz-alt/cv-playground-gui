// Copyright (c) 2021 Franz Alt
// This code is licensed under MIT license (see LICENSE.txt for details).

#include <string>

#include <QGuiApplication>
#include <QJSValue>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QString>

#include "document_handler.hpp"
#include "filter_image_item.hpp"
#include "syntax_highlighter.hpp"

const char * MODULE_URI = "com.cvpg.viewer";

static QJSValue applicationInfo(QQmlEngine * engine, QJSEngine * scriptEngine)
{
    Q_UNUSED(engine)

    QJSValue appInfo = scriptEngine->newObject();
    appInfo.setProperty("version", QString::fromStdString(std::string(CVPG_GUI_VERSION)));
    appInfo.setProperty("buildTimestamp", QString::fromStdString(std::string(BUILD_TIMESTAMP)));

    return appInfo;
}

int main(int argc, char * argv[])
{
#if QT_VERSION < QT_VERSION_CHECK(6, 0, 0)
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
#endif

    QGuiApplication app(argc, argv);
    app.setOrganizationName("cv-playground");
    app.setOrganizationDomain("https://github.com/franz-alt/cv-playground");
    app.setApplicationName("gui");

    qmlRegisterSingletonType("AppInfo", 1, 0, "AppInfo", applicationInfo);
    qmlRegisterType<FilterImageItem>(MODULE_URI, 1, 0, "FilterImageItem");
    qmlRegisterType<DocumentHandler>(MODULE_URI, 1, 0, "DocumentHandler");

    QQmlApplicationEngine engine;
    const QUrl url(QStringLiteral("qrc:/qml/main.qml"));

    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreated,
        &app,
        [url](QObject * obj, QUrl const & objUrl)
        {
            if (!obj && url == objUrl)
            {
                QCoreApplication::exit(-1);
            }
        },
        Qt::QueuedConnection
    );

    DocumentHandler documentHandler;
    engine.rootContext()->setContextProperty("documentHandler", &documentHandler);
    engine.load(url);

    return app.exec();
}
