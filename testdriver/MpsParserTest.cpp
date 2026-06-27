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
#include <QFile>
#include <QStringList>
#include <QtDebug>
#include <QFileInfo>
#include <QDir>
#include <QElapsedTimer>
#include "../MpsLexer.h"
#include "../MpsParser.h"
#include "../MpsParser2.h"
using namespace Mps;

QStringList collectFiles(const QDir& dir, const QStringList& suffix)
{
    QStringList res;
    QStringList files = dir.entryList(QDir::Dirs | QDir::NoDotAndDotDot, QDir::Name);

    foreach(const QString& f, files)
        res += collectFiles(QDir(dir.absoluteFilePath(f)), suffix);

    files = dir.entryList(suffix, QDir::Files, QDir::Name);
    foreach(const QString& f, files)
    {
        res.append(dir.absoluteFilePath(f));
    }
    return res;
}

static QString root;

static void checkLexer(const QStringList& files)
{
    int ok = 0;
    foreach(const QString& file, files)
    {
        Lexer lex;
        lex.setStream(file);
        lex.setIgnoreComments(false);

        qDebug() << "**** lexing" << file.mid(root.size());
        bool error = false;
        Token t = lex.nextToken();
        while( t.isValid() )
        {
            if( t.d_type == Tok_Invalid )
            {
                qCritical() << "  LEX ERROR:" << t.d_lineNr << t.d_colNr << t.d_val;
                error = true;
                break;
            }
            qDebug() << "  " << tokenTypeName(t.d_type) << t.d_lineNr << t.d_colNr
                     << t.d_val.left(60);
            t = lex.nextToken();
        }
        if( !error && t.isEof() )
            ok++;
        else if( !error )
            qCritical() << "  error:" << t.d_lineNr << t.d_colNr << t.d_val;
    }
    qDebug() << "#### lexer finished with" << ok << "files ok of total" << files.size() << "files";
}

static void checkParser(const QStringList& files)
{
    int ok = 0;

    class Lex : public Scanner
    {
    public:
        Lexer lex;
        Token next()
        {
            return lex.nextToken();
        }

        Token peek(int offset)
        {
            return lex.peekToken(offset);
        }
    };

    QElapsedTimer timer;
    timer.start();
    foreach(const QString& file, files)
    {
        Lex lex;
        lex.lex.setStream(file);
        Parser p(&lex);
        qDebug() << "**** parsing" << file.mid(root.size());
        p.RunParser();
        if( !p.errors.isEmpty() )
        {
            foreach(const Parser::Error& e, p.errors)
                qCritical() << e.path.mid(root.size()) << e.row << e.col << e.msg;
            // break;
        } else
            ok++;
    }
    qDebug() << "#### finished with" << ok << "files ok of total" << files.size()
             << "files" << "in" << timer.elapsed() << " [ms]";
}

static void checkParser2(const QStringList& files)
{
    int ok = 0;
    int totalLines = 0;
    int totalCommands = 0;

    class Lex : public Scanner
    {
    public:
        Lexer lex;
        Token next()
        {
            return lex.nextToken();
        }

        Token peek(int offset)
        {
            return lex.peekToken(offset);
        }
    };

    QElapsedTimer timer;
    timer.start();
    foreach(const QString& file, files)
    {
        Lex lex;
        lex.lex.setStream(file);
        Parser2 p(&lex);
        qDebug() << "**** parsing with ast" << file.mid(root.size() + 1);
        Routine* r = p.parse();
        if( !p.errors.isEmpty() )
        {
            foreach(const Parser2::Error& e, p.errors)
                qCritical() << e.path.mid(root.size() + 1) << e.row << e.col << e.msg;
        }
        else
        {
            ok++;
            totalLines += r->d_lines.size();
            for( int i = 0; i < r->d_lines.size(); i++ )
                totalCommands += r->d_lines[i]->d_commands.size();
        }
        delete r;
    }
    qDebug() << "#### finished with" << ok << "files ok of total" << files.size()
             << "files" << "in" << timer.elapsed() << " [ms]"
             << "(" << totalLines << "lines," << totalCommands << "commands)";
}

int main(int argc, char *argv[])
{
    QCoreApplication a(argc, argv);

    if( a.arguments().size() <= 1 )
    {
        qDebug() << "Usage: MpsParserTest [-lex|-ast] <file-or-dir>";
        qDebug() << "  -lex    Run lexer only (dump tokens)";
        qDebug() << "  -ast    Run AST-building parser (Parser2)";
        qDebug() << "  Otherwise runs generated parser";
        return -1;
    }

    bool lexOnly = false;
    bool astMode = false;
    QString path;
    for( int i = 1; i < a.arguments().size(); i++ )
    {
        if( a.arguments()[i] == "-lex" )
            lexOnly = true;
        else if( a.arguments()[i] == "-ast" )
            astMode = true;
        else
            path = a.arguments()[i];
    }

    if( path.isEmpty() )
    {
        qCritical() << "No file or directory specified";
        return -1;
    }

    QStringList files;
    QFileInfo info(path);
    if( info.isDir() )
    {
        files = collectFiles(info.filePath(), QStringList() << "*.mps" << "*.MPS" << "*.m" << "*.M" << "*.rou" << "*.MMP");
        root = info.filePath();
    }else
    {
        files.append(info.filePath());
        root = info.path();
    }

    if( files.isEmpty() )
    {
        qCritical() << "No MUMPS files found in" << path;
        return -1;
    }

    qDebug() << "Found" << files.size() << "MUMPS files";

    if( lexOnly )
        checkLexer(files);
    else if( astMode )
        checkParser2(files);
    else
        checkParser(files);

    return 0;
}
