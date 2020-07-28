TEMPLATE = app

QT += qml quick location xml network
#qtHaveModule(widgets): QT += widgets
CONFIG += qtquickcompiler

SUBDIRS += googlemaps

SOURCES += main.cpp \
    imageselector.cpp \
    gpxreader.cpp \
    exifreader.cpp \
    exif.cpp
RESOURCES += photosurface.qrc

target.path = ./
INSTALLS += target
ICON = resources/icon.png
macos: ICON = resources/photosurface.icns
win32: RC_FILE = resources/photosurface.rc


HEADERS += \
    imageselector.h \
    gpxreader.h \
    exifreader.h \
    exif.h

