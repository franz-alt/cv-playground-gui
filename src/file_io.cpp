// Copyright (c) 2021 Franz Alt
// This code is licensed under MIT license (see LICENSE.txt for details).

#include "file_io.hpp"

#include <QFile>
#include <QTextStream>

bool FileIo::write(QString const & url, QString const & data) const
{
    if (url.isEmpty())
    {
        return 0;
    }

    QFile file(url);

    if (!file.open(QFile::WriteOnly))
    {
        return false;
    }

    QTextStream out(&file);
    out << data;

    file.close();

    return true;
}

QString FileIo::read(QString const & url) const
{
    if (!QFile::exists(url))
    {
        return QString();
    }

    QFile file(url);

    if (!file.open(QFile::ReadOnly))
    {
        return QString();
    }

    QTextStream in(&file);
    return in.readAll();
}
