TEMPLATE = lib
TARGET = qpdf

CONFIG += dll
CONFIG += c++11

QT += widgets\
      webengine\
      webenginecore\
      webenginewidgets\
      webchannel

DEFINES += QPDFLIB_BUILD

HEADERS =\
    qpdfwidget.h \
    pdfjsbridge.h

SOURCES =\
    qpdfwidget.cpp \
    pdfjsbridge.cpp

RESOURCES += pdfview.qrc

DIST_DIR=$$PWD/../dist
CONFIG(debug, debug | release) {
    DESTDIR = $$DIST_DIR/debug
} else {
    DESTDIR = $$DIST_DIR/release
}
