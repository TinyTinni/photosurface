#ifndef IMAGESELECTOR_H
#define IMAGESELECTOR_H

#include <QObject>
#include <QQmlEngine>
#include <QDirIterator>
//#include <QFileSystemWatcher>

class ImageSelector : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QUrl image READ currentImage NOTIFY imageChanged)
    Q_PROPERTY(QUrl folder READ currentDir WRITE changeFolder NOTIFY folderChanged)

    QString m_current_file = "";
    int m_currentFile_idx = 0;
    QString m_current_dir = "";
    QFileInfoList m_files = {};
    //QFileSystemWatcher m_files_watcher = {};

public:
    explicit ImageSelector(QObject *parent = nullptr);

    QUrl currentImage(){return currentDir().toString() + "/" + m_current_file;}
    QUrl currentDir(){return QUrl::fromLocalFile(m_current_dir);}

public slots:

    void nextImage();
    void previousImage();
    void changeFolder(const QUrl& path);

signals:
    void imageChanged(const QUrl& path);
    void folderChanged(const QUrl& path);
    void newTrackFileFound(const QUrl& track);
};

#endif // IMAGESELECTOR_H
