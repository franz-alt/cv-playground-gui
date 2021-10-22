// Copyright (c) 2021 Franz Alt
// This code is licensed under MIT license (see LICENSE.txt for details).

#include "syntax_highlighter.hpp"

SyntaxHighlighter::SyntaxHighlighter(QTextDocument * parent)
    : QSyntaxHighlighter(parent)
{
    // comments
    {
        auto & rule = m_highlightingRules[Rules::Comment];
        rule.pattern = QRegularExpression(QStringLiteral("//[^\n]*"));
        rule.format.setForeground(Qt::darkGreen);

        m_multiLineCommentFormat.setForeground(Qt::darkGreen);

        m_commentStartExpression = QRegularExpression(QStringLiteral("/\\*"));
        m_commentEndExpression = QRegularExpression(QStringLiteral("\\*/"));
    }

    // functions
    {
        auto & rule = m_highlightingRules[Rules::Function];
        rule.pattern = QRegularExpression(QStringLiteral("\\b[A-Za-z0-9_]+(?=\\()"));
        rule.format.setForeground(Qt::blue);
        rule.format.setFontItalic(true);
    }

    // keywords
    {
        auto & rule = m_highlightingRules[Rules::Keyword];
        rule.pattern = QRegularExpression(QStringLiteral("\\b(catch|def|else|for|if|try|var|while)\\b"));
        rule.format.setForeground(Qt::darkBlue);
        rule.format.setFontWeight(QFont::Bold);
    }

    // quotations
    {
        auto & rule = m_highlightingRules[Rules::Quotation];
        rule.pattern = QRegularExpression(QStringLiteral("\".*\""));
        rule.format.setForeground(Qt::darkCyan);
    }
}

void SyntaxHighlighter::setColor(Rules rule, QColor color)
{
    if (rule == Rules::Comment)
    {
        m_multiLineCommentFormat.setForeground(color);
    }

    m_highlightingRules[rule].format.setForeground(color);
}

void SyntaxHighlighter::setState(bool enabled)
{
    m_enabled = enabled;

    rehighlight();
}

void SyntaxHighlighter::highlightBlock(QString const & text)
{
    setCurrentBlockState(0);

    if (!m_enabled)
    {
        return;
    }

    for (auto const & [ruleType, highlightRule] : m_highlightingRules)
    {
        QRegularExpressionMatchIterator matchIterator = highlightRule.pattern.globalMatch(text);

        while (matchIterator.hasNext())
        {
            QRegularExpressionMatch match = matchIterator.next();
            setFormat(match.capturedStart(), match.capturedLength(), highlightRule.format);
        }
    }

    int startIndex = 0;

    if (previousBlockState() != 1)
    {
        startIndex = text.indexOf(m_commentStartExpression);
    }

    while (startIndex >= 0)
    {
        QRegularExpressionMatch match = m_commentEndExpression.match(text, startIndex);

        int endIndex = match.capturedStart();

        int commentLength = 0;

        if (endIndex == -1)
        {
            setCurrentBlockState(1);
            commentLength = text.length() - startIndex;
        }
        else
        {
            commentLength = endIndex - startIndex + match.capturedLength();
        }

        setFormat(startIndex, commentLength, m_multiLineCommentFormat);

        startIndex = text.indexOf(m_commentStartExpression, startIndex + commentLength);
    }
}
