/*
* Copyright 2026 Rochus Keller <mailto:me@rochus-keller.ch>
*
* This file is part of the MUMPS 76 project.
*
* The following is the license that applies to this copy of the
* file. For a license to use the file under conditions
* other than those described here, please email to me@rochus-keller.ch.
*
* GNU General Public License Usage
* This file may be used under the terms of the GNU General Public
* License (GPL) versions 2.0 or 3.0 as published by the Free Software
* Foundation and appearing in the file LICENSE.GPL included in
* the packaging of this file. Please review the following information
* to ensure GNU General Public Licensing requirements will be met:
* http://www.fsf.org/licensing/licenses/info/GPLv2.html and
* http://www.gnu.org/copyleft/gpl.html.
*/

#include <QCoreApplication>
#include <QFileInfo>
#include <QDir>
#include <QtDebug>
#include "../MpsInterpreter.h"
#include "../MpsGlobalStore.h"
using namespace Mps;

void sleep_ms(unsigned long) {}

int main(int argc, char *argv[])
{
    QCoreApplication a(argc, argv);

    if( a.arguments().size() <= 1 )
    {
        qDebug() << "Usage: MpsInterpreterTest [-db <path>] [-i] [routine.mps] [search-dir ...]";
        qDebug() << "  -i             interactive (direct) mode";
        qDebug() << "  -db <path>     persistent global database file";
        qDebug() << "  routine.mps    run in batch mode (omit for interactive)";
        return -1;
    }

    QString routinePath;
    QString dbPath;
    QStringList searchPaths;
    bool interactive = false;

    for( int i = 1; i < a.arguments().size(); i++ )
    {
        if( a.arguments()[i] == "-db" && i + 1 < a.arguments().size() )
        {
            dbPath = a.arguments()[++i];
        }else if( a.arguments()[i] == "-i" )
        {
            interactive = true;
        }
        else if( routinePath.isEmpty() && !interactive )
            routinePath = a.arguments()[i];
        else
            searchPaths.append(a.arguments()[i]);
    }

    GlobalStore store;
    Interpreter interp;

    if( !dbPath.isEmpty() )
    {
        if( !store.open(dbPath) )
        {
            qCritical() << "Failed to open global database:" << dbPath;
            return -1;
        }
        interp.setGlobalStore(&store);
    }

    for( int i = 0; i < searchPaths.size(); i++ )
        interp.addSearchPath(searchPaths[i]);

    if( interactive )
    {
        interp.addSearchPath(QDir::currentPath());
        interp.runInteractive();
        return 0;
    }

    if( routinePath.isEmpty() )
    {
        qCritical() << "No routine specified";
        return -1;
    }

    QFileInfo fi(routinePath);
    if( !fi.exists() )
    {
        qCritical() << "File not found:" << routinePath;
        return -1;
    }

    interp.addSearchPath(fi.absolutePath());
    interp.run(fi.absoluteFilePath());

    if( !interp.errors.isEmpty() )
    {
        for( int i = 0; i < interp.errors.size(); i++ )
        {
            const Interpreter::Error& e = interp.errors[i];
            qCritical() << "Error line" << e.lineNr << ":" << e.msg;
        }
        return 1;
    }

    return 0;
}
