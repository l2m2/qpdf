TARGET = qpdf-reader

TEMPLATE = app

CONFIG += c++11

QT += widgets printsupport concurrent

HEADERS += mainwindow.h

SOURCES += mainwindow.cpp\
           main.cpp

RESOURCES += pdfviewer.qrc

INCLUDEPATH += ../qpdflib

DIST_DIR=$$PWD/../dist
CONFIG(debug, debug | release) {
    DESTDIR = $$DIST_DIR/debug
} else {
    DESTDIR = $$DIST_DIR/release
}
LIBS += -L$$DESTDIR
win32:LIBS += qpdf.lib
