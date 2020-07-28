#include "gpxreader.h"
#include <utility>

#include <QDebug>


GPXReader::GPXReader(QObject *parent) : QObject(parent)
{
}


bool GPXReader::startElement(const QString &namespaceURI, const QString &localName, const QString &qName, const QXmlAttributes &atts)
{
    Q_UNUSED(namespaceURI);
    Q_UNUSED(localName);
    if (qName == "trkseg")
    {
        m_paths.push_front(QGeoPath());
        m_currentPath = &m_paths.front();
    }

    if (qName == "trkpt")
    {
        if (m_currentPath == nullptr)
            return false;
        if (atts.count() < 2)
            return false;
        QGeoCoordinate coord;
        //todo error handling
        coord.setLatitude(atts.value("lat").toDouble());
        coord.setLongitude(atts.value("lon").toDouble());
        m_currentPath->addCoordinate(std::move(coord));
    }
    return true;
}

bool GPXReader::endElement(const QString &namespaceURI, const QString &localName, const QString &qName)
{
    Q_UNUSED(namespaceURI);
    Q_UNUSED(localName);
    if (qName == "trkseg")
    {
        m_currentPath = nullptr;
    }

    return true;
}

bool GPXReader::endDocument()
{
    emit tracksChanged(m_paths);
    emit trackChanged(m_paths[0]);
    return true;
}

bool GPXReader::parseXML(QIODevice* dev)
{
    QXmlSimpleReader xml_reader;
    QScopedPointer<QXmlInputSource> source{new QXmlInputSource(dev)};
    xml_reader.setContentHandler(this);

    return xml_reader.parse(source.get());
}

bool GPXReader::parseURL(const QUrl& url)
{
    QFile file(url.toLocalFile());
    return parseXML(&file);
}
