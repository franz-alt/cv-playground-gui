// Copyright (c) 2021 Franz Alt
// This code is licensed under MIT license (see LICENSE.txt for details).

#ifndef SYNTAX_HIGHLIGHTER_HPP
#define SYNTAX_HIGHLIGHTER_HPP

#include <QSyntaxHighlighter>

#include <QRegularExpression>
#include <QTextCharFormat>

#include <unordered_map>

class QTextDocument;

class SyntaxHighlighter : public QSyntaxHighlighter
{
    Q_OBJECT

public:
    SyntaxHighlighter(QTextDocument * parent = nullptr);

    // HINT: Workaround for the 'Error: Unknown method parameter type ...' problem.
    // HINT: Has to be the same as defined in DocumentHandler class.
    // TODO: FIX THIS !!!
    enum class Rules
    {
        Comment = 0,
        Function,
        Keyword,
        Quotation
    };

    void setColor(Rules rule, QColor color);

    void setState(bool enabled);

protected:
    void highlightBlock(QString const & text) override;

    struct HighlightingRule
    {
        QRegularExpression pattern;
        QTextCharFormat format;
    };

    std::unordered_map<Rules, HighlightingRule> m_highlightingRules;

    QTextCharFormat m_multiLineCommentFormat;

    QRegularExpression m_commentStartExpression;
    QRegularExpression m_commentEndExpression;

    bool m_enabled = true;
};

#endif // SYNTAX_HIGHLIGHTER_HPP
