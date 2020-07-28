#include "exifreader.h"

#include <QFile>
#include "exif.h"

#include <QDebug>

ExifReader::ExifReader(QObject *parent) : QObject(parent)
{

}


QGeoCoordinate ExifReader::coord()
{
    return m_coord;
}

void ExifReader::imageChanged(const QUrl& path)
{
    QFile file(path.toLocalFile());
    if (file.open(QIODevice::ReadOnly))
    {
        QByteArray data = file.readAll();
        easyexif::EXIFInfo info;
        if (int code = info.parseFrom(reinterpret_cast<unsigned char *>(data.data()), static_cast<unsigned>(data.size())))
        {
            qDebug() << "Error parsing EXIF: code " << code;
        }
        m_coord = QGeoCoordinate(info.GeoLocation.Latitude, info.GeoLocation.Longitude);
        emit dataChanged(m_coord);
    } else
    {
        qDebug() << "Can't open file:" << path.path();
    }

}
