// Copyright (c) 2021 Franz Alt
// This code is licensed under MIT license (see LICENSE.txt for details).

#include "document_handler.hpp"

#include <QQuickTextDocument>

DocumentHandler::DocumentHandler(QObject * parent)
    : QObject(parent)
{}

void DocumentHandler::setDocument(QQuickTextDocument * document)
{
    m_syntaxHighlighter = std::make_unique<SyntaxHighlighter>(document->textDocument());
}

void DocumentHandler::setSyntaxHighlightingColor(SyntaxHighlightingRules rule, QColor color)
{
    if (m_syntaxHighlighter)
    {
        m_syntaxHighlighter->setColor(static_cast<SyntaxHighlighter::Rules>(rule), color);
    }
}

void DocumentHandler::setSyntaxHighlightingState(bool enabled)
{
    if (m_syntaxHighlighter)
    {
        m_syntaxHighlighter->setState(enabled);
    }
}

void DocumentHandler::setText(QString text)
{
    if (m_text != text)
    {
        m_text = text;
        emit textChanged(m_text);
    }
}

QString DocumentHandler::text()
{
    return m_text;
}
