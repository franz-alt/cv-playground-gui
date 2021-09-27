// Copyright (c) 2021 Franz Alt
// This code is licensed under MIT license (see LICENSE.txt for details).

#ifndef FILTER_IMAGE_ITEM_HPP
#define FILTER_IMAGE_ITEM_HPP

#include <QQuickPaintedItem>

#include <QImage>
#include <QPointF>
#include <QString>

#include <any>
#include <cstdint>
#include <limits>

#include <boost/asynchronous/extensions/qt/qt_servant.hpp>

#include <libcvpg/imageproc/scripting/diagnostics/typedefs.hpp>

class FilterImageItem : public QQuickPaintedItem
                      , public boost::asynchronous::qt_servant<cvpg::imageproc::scripting::diagnostics::servant_job>
{
    Q_OBJECT

    Q_PROPERTY(Status status READ status NOTIFY statusChanged)

    Q_PROPERTY(QString url READ url WRITE setUrl NOTIFY urlChanged)

    Q_PROPERTY(int originalWidth READ originalWidth NOTIFY ratioChanged)
    Q_PROPERTY(int originalHeight READ originalHeight NOTIFY ratioChanged)

    Q_PROPERTY(QString filter READ filter WRITE setFilter NOTIFY filterChanged)

public:
    enum Status
    {
        NoImage,    // the selected image could not be found
        Loading,    // currently loading an image
        Failed,     // loading an image failed for any reason
        Success     // image was loaded successfully
    };
    Q_ENUM(Status)

    explicit FilterImageItem(QQuickItem * parent = Q_NULLPTR);

    virtual ~FilterImageItem() = default;

    virtual void paint(QPainter * painter) override;

public slots:
    void setUrl(QString const & url);
    void setFilter(QString const & filter);

signals:
    void statusChanged(Status status);
    void urlChanged(QString url);

    void ratioChanged();

    void filterChanged(QString filter);

    void renderingRequested();

private:
    void updateRenderBuffer(std::any image);

    void compileExpression();
    void filterImage();

    // functions for QML
    Status status() const;
    QString url() const;
    int originalWidth() const;
    int originalHeight() const;
    QString filter() const;

private slots:
    void onRenderingRequested();

private:
    Status m_status = Status::NoImage;

    QString m_url;

    QImage m_renderBuffer;

    std::uint8_t m_channels = 0;

    std::any m_rawImage;
    std::any m_filteredImage;

    std::size_t m_compileId = std::numeric_limits<std::size_t>::max();

    QString m_filter;
};

#endif // FILTER_IMAGE_ITEM_HPP
