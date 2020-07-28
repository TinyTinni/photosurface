#ifndef GPXREADER_H
#define GPXREADER_H

#include <QObject>
#include <QXmlSimpleReader>
#include <QGeoPath>
#include <QList>


//only a subset is implemented
//specification can be found here: https://www.topografix.com/GPX/1/1/
class GPXReader : public QObject, public QXmlDefaultHandler
{


    Q_OBJECT
    Q_PROPERTY(QList<QGeoPath> tracks READ tracks() NOTIFY tracksChanged)
    Q_PROPERTY(QGeoPath track READ track() NOTIFY trackChanged)

    QList<QGeoPath> m_paths;

    QGeoPath* m_currentPath = nullptr;

public:
    explicit GPXReader(QObject *parent = nullptr);

    bool startElement(const QString &namespaceURI, const QString &localName, const QString &qName, const QXmlAttributes &atts) override;
    bool endElement(const QString &namespaceURI, const QString &localName, const QString &qName) override;
    bool endDocument() override;

    const QList<QGeoPath>& tracks()const{return m_paths;}
    const QGeoPath& track()const{return m_paths[0];}


public slots:
    bool parseXML(QIODevice* dev);
    bool parseURL(const QUrl& url);


signals:
    void tracksChanged(const QList<QGeoPath>& tracks);
    void trackChanged(const QGeoPath& track);

public slots:

};


struct gpx
{
    QString version;
    QString creator;
    /*
     *
<metadata> metadataType </metadata> [0..1] ?
<wpt> wptType </wpt> [0..*] ?
<rte> rteType </rte> [0..*] ?
<trk> trkType </trk> [0..*] ?
<extensions> extensionsType </extensions> [0..1] ?
     */
};

#endif // GPXREADER_H
