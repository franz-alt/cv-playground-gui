// Copyright (c) 2021 Franz Alt
// This code is licensed under MIT license (see LICENSE.txt for details).

#include "filter_image_item.hpp"

#include <QPainter>

#include <algorithm>
#include <regex>
#include <thread>

#include <boost/asynchronous/algorithm/parallel_for.hpp>
#include <boost/asynchronous/algorithm/then.hpp>
#include <boost/asynchronous/scheduler_shared_proxy.hpp>
#include <boost/asynchronous/queue/lockfree_queue.hpp>
#include <boost/asynchronous/scheduler/multiqueue_threadpool_scheduler.hpp>
#include <boost/asynchronous/scheduler/single_thread_scheduler.hpp>
#include <boost/asynchronous/scheduler/threadpool_scheduler.hpp>

#include <libcvpg/core/image.hpp>
#include <libcvpg/imageproc/scripting/image_processor.hpp>

namespace {

// create a threadpool
auto pool = boost::asynchronous::make_shared_scheduler_proxy<
                boost::asynchronous::multiqueue_threadpool_scheduler<
                    boost::asynchronous::lockfree_queue<cvpg::imageproc::scripting::diagnostics::servant_job> > >(std::thread::hardware_concurrency(), std::string("threadpool"));

// a single-threaded world, where the image processor will live
auto scheduler = boost::asynchronous::make_shared_scheduler_proxy<
                     boost::asynchronous::single_thread_scheduler<
                         boost::asynchronous::lockfree_queue<cvpg::imageproc::scripting::diagnostics::servant_job> > >(std::string("image_processor"));

cvpg::imageproc::scripting::image_processor_proxy image_processor(scheduler, pool);

auto gray8_to_qimage(cvpg::image_gray_8bit image)
{
    auto qimage = std::make_shared<QImage>(image.width(), image.height(), QImage::Format(QImage::Format_Grayscale8));

    auto raw = image.data(0);

    auto process_row = [qimage, orig = raw.get(), width = image.width(), bytes_per_pixel = 1](size_t row) mutable
    {
        std::uint8_t * dst = qimage->bits() + row * qimage->bytesPerLine();
        const std::uint8_t * src = orig + row * width * bytes_per_pixel;
        memcpy(dst, src, width * bytes_per_pixel);
    };

    return boost::asynchronous::then(
        boost::asynchronous::parallel_for(
            static_cast<std::size_t>(0),
            static_cast<std::size_t>(image.height()),
            std::move(process_row),
            std::max(static_cast<std::size_t>(1000), static_cast<std::size_t>(image.height() / boost::thread::hardware_concurrency())),
            "FilterImageItem::gray8_to_qimage#parallel_for",
            1
        ),
        [qimage](auto expected)
        {
            expected.get();
            return *qimage;
        },
        "FilterImageItem::gray8_to_qimage"
    );
}

auto rgb8_to_qimage(cvpg::image_rgb_8bit image)
{
    auto qimage = std::make_shared<QImage>(image.width(), image.height(), QImage::Format(QImage::Format_RGB888));

    auto raw_r = image.data(0);
    auto raw_g = image.data(1);
    auto raw_b = image.data(2);

    auto process_row = [qimage, raw_red = raw_r.get(), raw_green = raw_g.get(), raw_blue = raw_b.get(), width = image.width(), bytes_per_pixel = 3](size_t row) mutable
    {
        std::uint8_t * dst = qimage->bits() + row * qimage->bytesPerLine();

        // TODO improve this slow code
        for (std::size_t x = 0; x < width; ++x)
        {
            dst[x * 3] = raw_red[row * width + x];
            dst[x * 3 + 1] = raw_green[row * width + x];
            dst[x * 3 + 2] = raw_blue[row * width + x];
        }
    };

    return boost::asynchronous::then(
        boost::asynchronous::parallel_for(
            static_cast<std::size_t>(0),
            static_cast<std::size_t>(image.height()),
            std::move(process_row),
            std::max(static_cast<std::size_t>(1000), static_cast<std::size_t>(image.height() / boost::thread::hardware_concurrency())),
            "FilterImageItem::rgb8_to_qimage#parallel_for",
            1
        ),
        [qimage](auto expected)
        {
            expected.get();
            return *qimage;
        },
        "FilterImageItem::rgb8_to_qimage"
    );
}

}

FilterImageItem::FilterImageItem(QQuickItem * parent)
    : QQuickPaintedItem(parent)
    , boost::asynchronous::qt_servant<cvpg::imageproc::scripting::diagnostics::servant_job>(
          boost::asynchronous::make_shared_scheduler_proxy<
              boost::asynchronous::single_thread_scheduler<
                  boost::asynchronous::lockfree_queue<cvpg::imageproc::scripting::diagnostics::servant_job> > >(std::string("FilterImageItem")))
{
    connect(this, SIGNAL(renderingRequested()), this, SLOT(onRenderingRequested()), Qt::QueuedConnection);

    connect(this, SIGNAL(widthChanged()), this, SLOT(onRenderingRequested()), Qt::QueuedConnection);
    connect(this, SIGNAL(heightChanged()), this, SLOT(onRenderingRequested()), Qt::QueuedConnection);
}

void FilterImageItem::paint(QPainter * painter)
{
    if (m_status != Success)
    {
        // don't paint anything if image isn't in success state
        return;
    }

    if (!m_renderBuffer.isNull())
    {
        painter->drawImage(0, 0, m_renderBuffer);
    }
}

void FilterImageItem::setUrl(QString const & url)
{
    if (url.isEmpty())
    {
        m_url.clear();
        emit urlChanged(m_url);

        m_status = NoImage;
        emit statusChanged(m_status);

        return;
    }

    m_url = std::move(url);

    // indicate that we're trying to load given PNG image
    m_status = Loading;
    emit statusChanged(m_status);

    // check if given URL is a PNG file
    const std::regex png_file_regex("file:\\/\\/.*\\.png");

    if (std::regex_match(m_url.toStdString(), png_file_regex))
    {
        // remove prefix 'file://' from URL ...
        const std::string filename = m_url.toStdString().substr(7);

        post_callback(
            [filename = std::move(filename)]() mutable -> std::pair<std::size_t, std::any>
            {
                // TODO resolve this wired compiler code because clang doesn't like the simple return case here

                auto [ channels, png ] = cvpg::read_png(filename);

                return { channels, std::move(png) };
            },
            [this, url = m_url](auto result)
            {
                try
                {
                    auto [ channels, png ] = result.get();

                    this->m_status = Success;
                    emit this->statusChanged(this->m_status);

                    this->m_channels = channels;
                    this->m_rawImage = std::move(png);

                    emit this->renderingRequested();

                    emit this->urlChanged(url);
                }
                catch (std::exception const & e)
                {
                    this->m_status = Failed;
                    emit this->statusChanged(this->m_status);

                    // TODO error handling!
                }
                catch (...)
                {
                    this->m_status = Failed;
                    emit this->statusChanged(this->m_status);

                    // TODO error handling!
                }
            },
            "FilterImageItem::setUrl#post_callback",
            1,
            1
        );
    }
}

void FilterImageItem::setFilter(QString const & filter)
{
    if (m_status != Success)
    {
        // don't set filter expression if image isn't in success state
        return;
    }

    m_filter = filter;

    emit filterChanged(m_filter);

    compileExpression();
}

void FilterImageItem::updateRenderBuffer(std::any image)
{
    if (m_channels == 1)
    {
        post_callback(
            [image = std::move(image)]() mutable
            {
                return gray8_to_qimage(std::any_cast<cvpg::image_gray_8bit>(std::move(image)));
            },
            [this](auto result)
            {
                try
                {
                    this->m_renderBuffer = std::move(result.get());

                    this->update();

                    emit this->ratioChanged();
                }
                catch (...)
                {
                    // TODO error handling
                }
            },
            "FilterImageItem::updateRenderBuffer#gray8_to_qimage",
            1,
            1
        );
    }
    else if (m_channels == 3)
    {
        post_callback(
            [image = std::move(image)]() mutable
            {
                return rgb8_to_qimage(std::any_cast<cvpg::image_rgb_8bit>(std::move(image)));
            },
            [this](auto result)
            {
                try
                {
                    this->m_renderBuffer = std::move(result.get());

                    this->update();

                    emit this->ratioChanged();
                }
                catch (...)
                {
                    // TODO error handling
                }
            },
            "FilterImageItem::updateRenderBuffer#rgb8_to_qimage",
            1,
            1
        );
    }
    else
    {
        // TODO error handling
    }
}

void FilterImageItem::compileExpression()
{
    image_processor.compile(
        m_filter.toStdString(),
        [this](std::size_t compileId)
        {
            this->m_compileId = compileId;

            this->filterImage();
        },
        [this](std::size_t, std::string message)
        {
            this->m_compileId = std::numeric_limits<std::size_t>::max();
        }
    );
}

void FilterImageItem::filterImage()
{
    if (m_compileId == std::numeric_limits<std::size_t>::max())
    {
        return;
    }

    if (m_channels == 1)
    {
        image_processor.evaluate(
            m_compileId,
            std::any_cast<cvpg::image_gray_8bit>(m_rawImage),
            [this](auto result)
            {
                if (result.type() == cvpg::imageproc::scripting::item::types::grayscale_8_bit_image)
                {
                    this->m_filteredImage = std::any_cast<cvpg::image_gray_8bit>(std::move(result.value()));

//                    this->updateRenderBuffer(this->m_filteredImage);
                }
                else
                {
                    // TODO report error

                    this->m_filteredImage.reset();
                }

                emit this->renderingRequested();
            }
        );
    }
    else if (m_channels == 3)
    {
        image_processor.evaluate(
            m_compileId,
            std::any_cast<cvpg::image_rgb_8bit>(m_rawImage),
            [this](auto result)
            {

            post_self([this, result](){

                if (result.type() == cvpg::imageproc::scripting::item::types::rgb_8_bit_image)
                {
                    this->m_filteredImage = std::any_cast<cvpg::image_rgb_8bit>(std::move(result.value()));

//                    this->updateRenderBuffer(this->m_filteredImage);

                }
                else
                {
                    // TODO report error

                    this->m_filteredImage.reset();

//                    this->updateRenderBuffer(this->m_rawImage);
                }

                emit this->renderingRequested();

            }, "", 0);

            }
        );
    }
}

FilterImageItem::Status FilterImageItem::status() const
{
    return m_status;
}

QString FilterImageItem::url() const
{
    return m_url;
}

int FilterImageItem::originalWidth() const
{
    if (m_status != Success)
    {
        return 0;
    }

    if (m_channels == 1)
    {
        auto image = std::any_cast<cvpg::image_gray_8bit>(m_rawImage);
        return image.width();
    }
    else if (m_channels == 3)
    {
        auto image = std::any_cast<cvpg::image_rgb_8bit>(m_rawImage);
        return image.width();
    }
    else
    {
        return 0;
    }
}

int FilterImageItem::originalHeight() const
{
    if (m_status != Success)
    {
        return 0;
    }

    if (m_channels == 1)
    {
        auto image = std::any_cast<cvpg::image_gray_8bit>(m_rawImage);
        return image.height();
    }
    else if (m_channels == 3)
    {
        auto image = std::any_cast<cvpg::image_rgb_8bit>(m_rawImage);
        return image.height();
    }
    else
    {
        return 0;
    }
}

QString FilterImageItem::filter() const
{
    if (m_status != Success)
    {
        return QString();
    }

    return m_filter;
}

void FilterImageItem::onRenderingRequested()
{
    if (m_status == Success)
    {
        updateRenderBuffer(m_filter.isEmpty() ? m_rawImage : m_filteredImage);
    }
}
