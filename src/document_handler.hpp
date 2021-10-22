// Copyright (c) 2021 Franz Alt
// This code is licensed under MIT license (see LICENSE.txt for details).

#ifndef DOCUMENTHANDLER_HPP
#define DOCUMENTHANDLER_HPP

#include <QObject>

#include <memory>

#include <QColor>
#include <QString>

#include "syntax_highlighter.hpp"

class QQuickTextDocument;

class DocumentHandler : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QString text READ text WRITE setText NOTIFY textChanged)

public:
    explicit DocumentHandler(QObject * parent = nullptr);

    Q_INVOKABLE void setDocument(QQuickTextDocument * document);

    enum class SyntaxHighlightingRules
    {
        Comment = 0,
        Function,
        Keyword,
        Quotation
    };
    Q_ENUM(SyntaxHighlightingRules)

    Q_INVOKABLE void setSyntaxHighlightingColor(SyntaxHighlightingRules rule, QColor color);

    Q_INVOKABLE void setSyntaxHighlightingState(bool enabled);

public slots:
    void setText(QString text);

signals:
    void textChanged(QString text);

private:
    // functions for QML
    QString text();

    QString m_text;

    std::unique_ptr<SyntaxHighlighter> m_syntaxHighlighter;
};

#endif // DOCUMENTHANDLER_HPP
