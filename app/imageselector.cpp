#include "imageselector.h"

#include <QStandardPaths>
#include <QMimeDatabase>
#include <QImageReader>
#include <QSettings>

static QStringList imageNameFilters()
{
    QStringList result = {"*.jpg"};
    return result;
}


ImageSelector::ImageSelector(QObject *parent) : QObject(parent)
{
    const QStringList nameFilters = imageNameFilters();

    QSettings settings;
    m_current_dir = settings.value("imageselector/currentFolder", QStandardPaths::standardLocations(QStandardPaths::PicturesLocation)[0]).toString();


//    connect(&m_files_watcher, &QFileSystemWatcher::directoryChanged, this, [this](const QString& path)
//    {
//        this->changeFolder(QUrl::fromLocalFile(path));
//    });
    //changeFolder(initialUrl);
    m_files = QDir(m_current_dir).entryInfoList(nameFilters, QDir::Files, QDir::Name);
    if (m_files.empty())
        return;
    m_currentFile_idx = 0;
    m_current_file = m_files[m_currentFile_idx].fileName();

}

void ImageSelector::nextImage()
{
    if (m_currentFile_idx < m_files.size()-1)
    {
        ++m_currentFile_idx;
        m_current_file = m_files[m_currentFile_idx].fileName();
    }
    emit imageChanged(currentImage());
}
void ImageSelector::previousImage()
{
    if (m_currentFile_idx > 0)
    {
        --m_currentFile_idx;
        m_current_file = m_files[m_currentFile_idx].fileName();
    }
    emit imageChanged(currentImage());
}

void ImageSelector::changeFolder(const QUrl& path)
{
    if (!path.isValid())
        return;

    QString dir = path.toLocalFile();
    QSettings settings;
    settings.setValue("imageselector/currentFolder", dir);

    // todo: if same directory, keep iterator on current image and just update the list
//    if (!m_files_watcher.directories().empty())
//        m_files_watcher.removePaths(m_files_watcher.directories());
//    m_files_watcher.addPath(dir);

    m_current_dir = dir;

    const QStringList nameFilters = imageNameFilters();
    m_files = QDir(dir).entryInfoList(nameFilters, QDir::Files, QDir::Name);
    m_currentFile_idx = 0;
    if (m_files.empty())
        return;

    m_current_file = m_files[m_currentFile_idx].fileName();
    emit folderChanged(path);
    emit imageChanged(currentImage());

    auto track_files = QDir(dir).entryInfoList(QStringList("*.gpx"), QDir::Files);
    if (!track_files.empty())
        emit newTrackFileFound(QUrl::fromLocalFile(track_files[0].filePath()));
}

