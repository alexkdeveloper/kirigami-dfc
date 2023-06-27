
#include "fileio.h"
#include <QFile>
#include <QUrl>
#include <QTextStream>

FileIO::FileIO()
{

}

void FileIO::save(QString text, QString path){
    QFile file(path);

    if(file.open(QIODevice::ReadWrite)){
    QTextStream stream(&file);
    stream << text << endl;
    }

    return;
}

bool FileIO::exists(QString path){
    QFile file(path);

    return file.exists();
}

QString FileIO::toPath(QString path){

    return QUrl(path).toLocalFile();
}

FileIO::~FileIO()
{

}
