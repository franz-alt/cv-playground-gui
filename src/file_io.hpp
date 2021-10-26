// Copyright (c) 2021 Franz Alt
// This code is licensed under MIT license (see LICENSE.txt for details).

#ifndef FILE_IO_HPP
#define FILE_IO_HPP

#include <QObject>

#include <QString>

class FileIo : public QObject
{
    Q_OBJECT

public slots:
    bool write(QString const & url, QString const & data) const;

    QString read(QString const & url) const;

signals:

};

#endif // FILE_IO_HPP
