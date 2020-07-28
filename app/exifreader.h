#ifndef EXIFREADER_H
#define EXIFREADER_H

#include <QObject>
#include <QUrl>
#include <QGeoCoordinate>

class ExifReader : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QGeoCoordinate coord READ coord() NOTIFY dataChanged)

    QGeoCoordinate m_coord = {};
public:
    explicit ExifReader(QObject *parent = nullptr);
    QGeoCoordinate coord();

signals:
    void dataChanged(QGeoCoordinate coord);

public slots:
    void imageChanged(const QUrl& path);
};

#endif // EXIFREADER_H
