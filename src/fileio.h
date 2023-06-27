
#include <QObject>

#ifndef FILEIO_H
#define FILEIO_H


class FileIO : public QObject
{

    Q_OBJECT

public:
    FileIO();
    Q_INVOKABLE void save(QString text, QString path);
    Q_INVOKABLE bool exists(QString path);
    Q_INVOKABLE QString toPath(QString path);
    ~FileIO();

};

#endif // FILEIO_H
