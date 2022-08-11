/*
                          qpdf

    Copyright (C) 2015 Arthur Benilov,
    arthur.benilov@gmail.com
    This program is free software; you can redistribute it and/or
    modify it under the terms of the GNU Lesser General Public
    License as published by the Free Software Foundation; either
    version 2.1 of the License, or (at your option) any later version.
    This software is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
    Lesser General Public License for more details.
*/

#include <QAction>
#include <QToolBar>
#include <QIcon>
#include <QFileDialog>
#include <QStandardPaths>
#include <QFileInfo>
#include <QPainter>
#include <QStandardPaths>
#include <QtPrintSupport>
#include <QtConcurrent>
#include "QPdfWidget"
#include "mainwindow.h"

static QColor str2color(const QString &str)
{
    QColor color;
    if (str.startsWith('#') && str.length() == 9) {
        QString c = str.left(7);
        QString a = str.right(2);
        color.setNamedColor(c);
        color.setAlpha(a.toInt(0,16));
    } else {
        color.setNamedColor(str);
    }
    return color;
}

QIcon MainWindow::icon(const QString &name)
{
    QString iconName = name;
    QString colorName;
    QStringList parts = name.split('.', Qt::SkipEmptyParts);
    auto count = parts.count();
    if (count > 1) {
        iconName = parts.at(0);
        colorName = parts.at(1);
    }
    QString fileName = QString(":/icons/%1.svg").arg(iconName);
    if (fileName.isEmpty()) {
        return QIcon();
    }
    if (!colorName.isEmpty()) {
        QPixmap pixmap(fileName);
        if (pixmap.isNull()) return QIcon();
        if (colorName.toLower() != "transparent") {
            QPainter painter(&pixmap);
            painter.setCompositionMode(QPainter::CompositionMode_SourceIn);
            painter.fillRect(pixmap.rect(), str2color(colorName));
            painter.end();
        }
        return QIcon(pixmap);
    }
    return QIcon(fileName);
}

QVariant runSync(std::function<QVariant ()> func)
{
    QFutureWatcher<QVariant> watcher;
    QEventLoop eventLoop;
    QObject::connect(&watcher, SIGNAL(finished()),
                     &eventLoop, SLOT(quit()));
    QFuture<QVariant> future = QtConcurrent::run(func);
    watcher.setFuture(future);
    eventLoop.exec(QEventLoop::ExcludeUserInputEvents);
    return future.result();
}

MainWindow::MainWindow(QWidget *pParent, Qt::WindowFlags flags)
    : QMainWindow(pParent, flags)
{
    setWindowIcon(icon("file-earmark-pdf.#4D9BE8"));

    m_pPdfWidget = new QPdfWidget();
    setCentralWidget(m_pPdfWidget);

    createActions();
    createToolBar();
}

void MainWindow::loadFile(const QString &path)
{
    if (m_pPdfWidget->loadFile(path)) {
        // Update window title with the file name
        QFileInfo fi(path);
        setWindowTitle(fi.fileName());
        m_fileName = path;
    }
}

void MainWindow::createActions()
{
    m_pOpenFileAction = new QAction(icon("folder2-open.#4D9BE8"), tr("&Open..."), this);
    connect(m_pOpenFileAction, &QAction::triggered, this, &MainWindow::onOpenFile);
    m_pPrintAction = new QAction(icon("printer.#4D9BE8"), tr("&Print"), this);
    connect(m_pPrintAction, &QAction::triggered, this, &MainWindow::onPrint);
}

void MainWindow::createToolBar()
{
    QToolBar *pToolBar = addToolBar(tr("File"));
    pToolBar->setMovable(false);
    pToolBar->addAction(m_pOpenFileAction);
    pToolBar->addAction(m_pPrintAction);
}

void MainWindow::onOpenFile()
{
    QString fileName = QFileDialog::getOpenFileName(this, tr("Open PDF file"),
                                                    QStandardPaths::writableLocation(QStandardPaths::DocumentsLocation),
                                                    tr("PDF file (*.pdf)"));
    if (fileName.isEmpty()) {
        return;
    }
    loadFile(fileName);
}

static bool pdf2png(const QString &pdfFileName, const QString &outputDir, int fromPage, int toPage)
{
    qDebug() << __FUNCTION__ << pdfFileName << outputDir << fromPage << toPage;
    QString program = QCoreApplication::applicationDirPath() + QDir::separator() + "pdftopng.exe";
    QStringList args;
    args << "-gray" << "-f" << QString::number(fromPage) << "-l" << QString::number(toPage) <<  "-r" << "1200" << pdfFileName << outputDir;
    QProcess process;
    process.start(program, args);
    bool ok = process.waitForFinished(400000);
    return ok;
}

void MainWindow::onPrint()
{
    if (m_fileName.isEmpty())
        return;
    QPrinter printer(QPrinter::HighResolution);
    printer.setResolution(1200);
    printer.setFullPage(true);
    printer.setPageMargins(QMarginsF(0, 0, 0, 0));
    QString filePath = m_fileName;
    QPrintDialog dialog(&printer, this);
    if (dialog.exec() == QDialog::Accepted) {
        int from = printer.fromPage();
        int to = printer.toPage();
        QString dirName = QStandardPaths::writableLocation(QStandardPaths::TempLocation) + QDir::separator()
                + QUuid::createUuid().toString() + QDir::separator();
        QDir dir(dirName);
        if (!dir.mkpath(dirName)) {
            qWarning() << __FUNCTION__ << "mkpath failed.";
            return;
        }
        bool ok = runSync([dirName, filePath, from, to](){
            if (!pdf2png(filePath, dirName, from, to)) {
                qWarning() << "pdf2png failed.";
                return false;
            }
            return true;
        }).toBool();
        if (!ok)
            return;
        QPainter painter(&printer);
        QDirIterator it(dirName, QStringList() << "*.png", QDir::Files);
        while (it.hasNext()) {
            QString pngFileName = it.next();
            QPixmap pixmap(pngFileName);
            painter.drawPixmap(0, 0, pixmap);
            if (it.hasNext())
                printer.newPage();
        }
        painter.end();
        dir.removeRecursively();
    }
}
