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

#include "MpsInterpreter.h"
#include <QCoreApplication>
#include <QFileInfo>
#include <QDir>
#include <QtDebug>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#ifdef Q_OS_WIN
#include <windows.h>
#include <io.h>
#else
#include <termios.h>
#include <unistd.h>
#include <sys/ioctl.h>
#endif

using namespace Mps;

#ifdef Q_OS_WIN
static DWORD s_origInputMode;
static DWORD s_origOutputMode;
static HANDLE s_hStdin;
static HANDLE s_hStdout;
#else
static struct termios s_origTermios;
#endif
static bool s_rawMode = false;

static void enableRawMode()
{
    if( s_rawMode )
        return;
#ifdef Q_OS_WIN
    s_hStdin = GetStdHandle(STD_INPUT_HANDLE);
    s_hStdout = GetStdHandle(STD_OUTPUT_HANDLE);
    GetConsoleMode(s_hStdin, &s_origInputMode);
    DWORD mode = s_origInputMode;
    mode &= ~(ENABLE_ECHO_INPUT | ENABLE_LINE_INPUT | ENABLE_PROCESSED_INPUT);
    SetConsoleMode(s_hStdin, mode);
    // Enable VT processing for ANSI escape codes on stdout
    GetConsoleMode(s_hStdout, &s_origOutputMode);
    DWORD outMode = s_origOutputMode | ENABLE_VIRTUAL_TERMINAL_PROCESSING;
    SetConsoleMode(s_hStdout, outMode);
#else
    struct termios raw;
    tcgetattr(STDIN_FILENO, &s_origTermios);
    raw = s_origTermios;
    raw.c_lflag &= ~(ECHO | ICANON | ISIG);
    raw.c_cc[VMIN] = 1;
    raw.c_cc[VTIME] = 0;
    tcsetattr(STDIN_FILENO, TCSAFLUSH, &raw);
#endif
    s_rawMode = true;
}

static void disableRawMode()
{
    if( !s_rawMode )
        return;
#ifdef Q_OS_WIN
    SetConsoleMode(s_hStdin, s_origInputMode);
    SetConsoleMode(s_hStdout, s_origOutputMode);
#else
    tcsetattr(STDIN_FILENO, TCSAFLUSH, &s_origTermios);
#endif
    s_rawMode = false;
}

static int readChar()
{
#ifdef Q_OS_WIN
    DWORD n;
    INPUT_RECORD rec;
    for(;;)
    {
        if( !ReadConsoleInputA(s_hStdin, &rec, 1, &n) || n == 0 )
            return -1;
        if( rec.EventType == KEY_EVENT && rec.Event.KeyEvent.bKeyDown )
        {
            WORD vk = rec.Event.KeyEvent.wVirtualKeyCode;
            char ch = rec.Event.KeyEvent.uChar.AsciiChar;
            // Map virtual key codes to escape sequences for uniform handling
            if( vk == VK_UP )    return 0x100; // special: up
            if( vk == VK_DOWN )  return 0x101; // special: down
            if( vk == VK_RIGHT ) return 0x102; // special: right
            if( vk == VK_LEFT )  return 0x103; // special: left
            if( vk == VK_HOME )  return 0x104; // special: home
            if( vk == VK_END )   return 0x105; // special: end
            if( vk == VK_DELETE) return 0x106; // special: delete
            if( ch != 0 )
                return (unsigned char)ch;
        }
    }
#else
    unsigned char c;
    if( read(STDIN_FILENO, &c, 1) != 1 )
        return -1;
    if( c == 0x1b )
    {
        // try to read escape sequence
        unsigned char seq[3];
        if( read(STDIN_FILENO, &seq[0], 1) != 1 ) return 0x1b;
        if( seq[0] == '[' )
        {
            if( read(STDIN_FILENO, &seq[1], 1) != 1 ) return 0x1b;
            if( seq[1] == 'A' ) return 0x100; // up
            if( seq[1] == 'B' ) return 0x101; // down
            if( seq[1] == 'C' ) return 0x102; // right
            if( seq[1] == 'D' ) return 0x103; // left
            if( seq[1] == 'H' ) return 0x104; // home
            if( seq[1] == 'F' ) return 0x105; // end
            if( seq[1] == '3' )
            {
                unsigned char t;
                if( read(STDIN_FILENO, &t, 1) == 1 && t == '~' )
                    return 0x106; // delete
            }
        }
        else if( seq[0] == 'O' )
        {
            if( read(STDIN_FILENO, &seq[1], 1) != 1 ) return 0x1b;
            if( seq[1] == 'H' ) return 0x104; // home
            if( seq[1] == 'F' ) return 0x105; // end
        }
        return 0x1b;
    }
    return c;
#endif
}

#ifdef _WIN32
#include <windows.h>

void sleep_ms(unsigned long ms)
{
    Sleep(ms);   /* milliseconds */
}

#else
#include <time.h>
#include <unistd.h>

void sleep_ms(unsigned long ms)
{
#if defined(_POSIX_C_SOURCE) && (_POSIX_C_SOURCE >= 199309L)
    struct timespec ts;
    ts.tv_sec  = ms / 1000;
    ts.tv_nsec = (long)(ms % 1000) * 1000000L;
    nanosleep(&ts, 0);
#else
    sleep(ms / 1000);
    usleep((ms % 1000) * 1000);
#endif
}
#endif

struct LineEditor
{
    QList<QByteArray> history;
    int histIdx;
    QByteArray buf;
    int cursor;
    QByteArray prompt;

    LineEditor() : histIdx(0), cursor(0), prompt(">") {}

    void redraw()
    {
        // move to beginning, clear line, print prompt + buffer, reposition cursor
        fputs("\r\x1b[2K", stdout);
        fputs(prompt.constData(), stdout);
        fputs(buf.constData(), stdout);
        // move cursor to correct position
        int back = buf.size() - cursor;
        if( back > 0 )
            fprintf(stdout, "\x1b[%dD", back);
        fflush(stdout);
    }

    // returns a line (without newline), or null QByteArray on EOF/Ctrl-D
    QByteArray readLine()
    {
        buf = QByteArray("");
        cursor = 0;
        histIdx = history.size();
        redraw();

        for(;;)
        {
            int ch = readChar();
            if( ch < 0 ) // EOF
            {
                fputs("\n", stdout);
                return QByteArray();
            }

            switch( ch )
            {
            case '\r':
            case '\n':
                fputs("\n", stdout);
                fflush(stdout);
                if( !buf.trimmed().isEmpty() )
                    history.append(buf);
                return buf;

            case 4: // Ctrl-D
                if( buf.isEmpty() )
                {
                    fputs("\n", stdout);
                    return QByteArray();
                }
                // Otherwise: delete char at cursor (like Delete key)
                if( cursor < buf.size() )
                {
                    buf.remove(cursor, 1);
                    redraw();
                }
                break;

            case 3: // Ctrl-C
                buf.clear();
                cursor = 0;
                fputs("^C\n", stdout);
                redraw();
                break;

            case 127: // Backspace (most terminals)
            case 8:   // Ctrl-H / Backspace
                if( cursor > 0 )
                {
                    buf.remove(cursor - 1, 1);
                    cursor--;
                    redraw();
                }
                break;

            case 1: // Ctrl-A (Home)
            case 0x104: // Home
                cursor = 0;
                redraw();
                break;

            case 5: // Ctrl-E (End)
            case 0x105: // End
                cursor = buf.size();
                redraw();
                break;

            case 21: // Ctrl-U: clear line
                buf.clear();
                cursor = 0;
                redraw();
                break;

            case 11: // Ctrl-K: kill to end of line
                buf.truncate(cursor);
                redraw();
                break;

            case 12: // Ctrl-L: clear screen
                fputs("\x1b[2J\x1b[H", stdout);
                redraw();
                break;

            case 0x100: // Up
                if( histIdx > 0 )
                {
                    histIdx--;
                    buf = history[histIdx];
                    cursor = buf.size();
                    redraw();
                }
                break;

            case 0x101: // Down
                if( histIdx < history.size() - 1 )
                {
                    histIdx++;
                    buf = history[histIdx];
                    cursor = buf.size();
                }
                else
                {
                    histIdx = history.size();
                    buf.clear();
                    cursor = 0;
                }
                redraw();
                break;

            case 0x102: // Right
                if( cursor < buf.size() )
                {
                    cursor++;
                    redraw();
                }
                break;

            case 0x103: // Left
                if( cursor > 0 )
                {
                    cursor--;
                    redraw();
                }
                break;

            case 0x106: // Delete
                if( cursor < buf.size() )
                {
                    buf.remove(cursor, 1);
                    redraw();
                }
                break;

            default:
                if( ch >= 32 && ch < 127 )
                {
                    buf.insert(cursor, (char)ch);
                    cursor++;
                    redraw();
                }
                break;
            }
        }
    }
};

#define MPS_CHROME(o)   fprintf(o, "MUMPS 76 Interpreter\n"); \
                        fprintf(o, "(c) 2026 Rochus Keller <mailto:me@rochus-keller.ch>\n"); \
                        fprintf(o, "Available under GPL 2 or 3\n");

static void printUsage(const char* progName)
{
    MPS_CHROME(stderr)
    fprintf(stderr, "Usage: mumps [options] [routine.mps] [search-dir ...]\n\n", progName);
    fprintf(stderr, "Options:\n");
    fprintf(stderr, "  -db <path>    Path to global database file\n");
    fprintf(stderr, "  -h, --help    Show this help message\n");
    fprintf(stderr, "\nIf no routine is specified, starts in interactive (direct) mode.\n");
    fprintf(stderr, "If no -db is given, uses 'mumps.db' in the current directory.\n");
}

int main(int argc, char* argv[])
{
    QCoreApplication app(argc, argv);

    QString routinePath;
    QString dbPath;
    QStringList searchPaths;

    const QStringList args = app.arguments();
    for( int i = 1; i < args.size(); i++ )
    {
        const QString arg = args[i];
        if( arg == "-db" && i + 1 < args.size() )
        {
            dbPath = args[++i];
        }
        else if( arg == "-h" || arg == "--help" )
        {
            printUsage(argv[0]);
            return 0;
        }
        else if( routinePath.isEmpty() && !arg.startsWith("-") )
        {
            QFileInfo fi(arg);
            if( fi.exists() && fi.isFile() )
                routinePath = fi.absoluteFilePath();
            else if( fi.exists() && fi.isDir() )
                searchPaths.append(fi.absoluteFilePath());
            else
            {
                fprintf(stderr, "Error: file not found: %s\n",
                             arg.toUtf8().constData());
                return 1;
            }
        }
        else
        {
            QFileInfo fi(arg);
            if( fi.exists() && fi.isDir() )
                searchPaths.append(fi.absoluteFilePath());
            else
                searchPaths.append(arg);
        }
    }

    // Default database path
    if( dbPath.isEmpty() )
        dbPath = QDir::currentPath() + "/mumps.db";


    Interpreter interp;
    interp.addSearchPath(QDir::currentPath());

    for( int i = 0; i < searchPaths.size(); i++ )
        interp.addSearchPath(searchPaths[i]);

    // Batch mode: run a routine file
    if( !routinePath.isEmpty() )
    {
        QFileInfo fi(routinePath);
        interp.addSearchPath(fi.absolutePath());
        interp.run(routinePath);

        if( !interp.errors.isEmpty() )
        {
            for( int i = 0; i < interp.errors.size(); i++ )
            {
                const Interpreter::Error& e = interp.errors[i];
                fprintf(stderr, "Error line %u: %s\n",
                             (unsigned)e.lineNr, e.msg.toUtf8().constData());
            }
            return 1;
        }
        return 0;
    }

    // Interactive mode
    bool isTty = true;
#ifdef Q_OS_WIN
    isTty = (_isatty(_fileno(stdin)) != 0);
#else
    isTty = (isatty(STDIN_FILENO) != 0);
#endif

    if( !isTty )
    {
        // Piped input: use simple fgets loop (no line editing)
        char buf[4096];
        while( fgets(buf, sizeof(buf), stdin) )
        {
            QByteArray line(buf);
            if( line.endsWith('\n') ) line.chop(1);
            if( line.endsWith('\r') ) line.chop(1);
            if( line.isEmpty() ) continue;
            if( !interp.executeLine(line) )
                break;
        }
        return 0;
    }

    // TTY interactive mode with line editing
    enableRawMode();
    atexit(disableRawMode);

    LineEditor editor;

    MPS_CHROME(stdout);
    fprintf(stdout, "Run with -h for options. Type HALT to exit.\n");
    fflush(stdout);

    for(;;)
    {
        QByteArray line = editor.readLine();
        if( line.isNull() ) // EOF
            break;
        if( line.trimmed().isEmpty() )
            continue;
        // temporarily disable raw mode for interpreter I/O
        disableRawMode();
        bool cont = interp.executeLine(line);
        // ensure cursor is on a fresh line before re-entering the editor
        if( interp.xPos() != 0 )
            fputc('\n', stdout);
        fflush(stdout);
        enableRawMode();
        if( !cont )
            break;
    }

    disableRawMode();
    return 0;
}
