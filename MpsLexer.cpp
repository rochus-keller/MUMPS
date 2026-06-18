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

/*
  Line-oriented, stateful lexer.
  Uses the double-space convention as in RSM/YottaDB.
  The most complex of my projects!

  Mumps has syntactically significant whitespace:
  - One space separates command word from arguments
  - One space after arguments marks start of next command
  - Command words are also valid variable names; the lexer tracks "command position" to emit keyword tokens vs. ident tokens.
  - A lookahead heuristic distinguishes argument-separating spaces from command-separating spaces.

*/

#include "MpsLexer.h"
#include <QFile>
#include <QIODevice>
#include <QtDebug>
using namespace Mps;


struct Comand {
    const char* full;
    TokenType tt;
};

static const Comand s_commands[] = {
    { "BREAK",  Tok_BREAK },
    { "CLOSE",  Tok_CLOSE },
    { "DO",     Tok_DO },
    { "ELSE",   Tok_ELSE },
    { "FOR",    Tok_FOR },
    { "GOTO",   Tok_GOTO },
    { "HALT",   Tok_HALT },   // also matches HANG (merged)
    { "IF",     Tok_IF },
    { "JOB",    Tok_JOB },
    { "KILL",   Tok_KILL },
    { "LOCK",   Tok_LOCK },
    { "NEW",    Tok_NEW },
    { "OPEN",   Tok_OPEN },
    { "QUIT",   Tok_QUIT },
    { "READ",   Tok_READ },
    { "SET",    Tok_SET },
    { "USE",    Tok_USE },
    { "VIEW",   Tok_VIEW },
    { "WRITE",  Tok_WRITE },
    { "XECUTE", Tok_XECUTE },
    { 0, Tok_Invalid }
};

TokenType Lexer::matchCommand(const QByteArray& word)
{
    if( word.isEmpty() )
        return Tok_Invalid;

    const QByteArray upper = word.toUpper();

    // Z-commands: any word starting with Z
    if( upper[0] == 'Z' )
        return Tok_ZCMD;

    // Special case: H can be HALT or HANG; we emit Tok_HALT for both
    if( upper[0] == 'H' )
    {
        if( upper.size() == 1 )
            return Tok_HALT;
        if( QByteArray("HALT").startsWith(upper) || QByteArray("HANG").startsWith(upper) )
            return Tok_HALT;
        return Tok_Invalid;
    }

#if 1
    // word must be a prefix of a full command name
    for( int i = 0; s_commands[i].full; i++ )
    {
        const QByteArray full(s_commands[i].full);
        if( full.startsWith(upper) )
            return s_commands[i].tt;
    }
#else
    return tokenTypeFromString(upper); // too generic
#endif
    return Tok_Invalid;
}

Lexer::Lexer()
    : d_sloc(0), d_lineNr(0), d_colNr(0),
      d_lastToken(Tok_Invalid), d_ignoreComments(true), d_lineCounted(false),
      d_cmdMode(false), d_lineStart(true), d_labelDone(false), d_hasPostcond(false),
      d_parenDepth(0)
{
}

void Lexer::setStream(QIODevice* in, const QString& sourcePath)
{
    if( in == 0 )
        setStream(sourcePath);
    else
        setStream(in->readAll(), sourcePath);
}

void Lexer::setStream(const QByteArray& source, const QString& sourcePath)
{
    d_lineNr = 0;
    d_colNr = 0;
    d_sourcePath = sourcePath;
    d_lastToken = Token(Tok_Invalid);
    d_sloc = 0;
    d_lineCounted = false;
    d_cmdMode = false;
    d_lineStart = true;
    d_labelDone = false;
    d_hasPostcond = false;
    d_parenDepth = 0;
    d_buffer.clear();

    if( d_in.isOpen() )
        d_in.close();
    d_in.buffer() = source;
    d_in.open(QIODevice::ReadOnly);
}

bool Lexer::setStream(const QString& sourcePath)
{
    QFile file(sourcePath);
    if( !file.open(QIODevice::ReadOnly) )
        return false;
    setStream(&file, sourcePath);
    return true;
}

Token Lexer::nextToken()
{
    Token t;
    if( !d_buffer.isEmpty() )
    {
        t = d_buffer.first();
        d_buffer.pop_front();
    } else
        t = nextTokenImp();
    if( t.d_type == Tok_Comment && d_ignoreComments )
        t = nextToken();
    d_prevToken = d_lastToken;
    d_lastToken = t;
    return t;
}

Token Lexer::peekToken(quint8 lookAhead)
{
    Q_ASSERT(lookAhead > 0);
    while( d_buffer.size() < lookAhead )
    {
        Token t = nextTokenImp();
        if( t.d_type == Tok_Comment && d_ignoreComments )
            continue;
        d_buffer.push_back(t);
    }
    return d_buffer[lookAhead - 1];
}

void Lexer::nextLine()
{
    d_colNr = 0;
    d_lineNr++;
    d_line = d_in.readLine();
    d_lineCounted = false;

    if( d_line.endsWith("\r\n") )
        d_line.chop(2);
    else if( d_line.endsWith('\n') || d_line.endsWith('\r') )
        d_line.chop(1);
}

int Lexer::lookAhead(int off) const
{
    if( int(d_colNr + off) < d_line.size() )
        return (quint8)d_line[d_colNr + off];
    else
        return 0;
}

Token Lexer::token(TokenType tt, int len, const QByteArray& val)
{
    if( tt != Tok_Invalid && tt != Tok_Comment && tt != Tok_Eof && tt != Tok_Newline )
        countLine();
    Token t(tt, d_lineNr, d_colNr + 1, len, val);
    d_colNr += len;
    t.d_sourcePath = d_sourcePath;
    return t;
}

void Lexer::countLine()
{
    if( !d_lineCounted )
    {
        d_sloc++;
        d_lineCounted = true;
    }
}

Token Lexer::nextTokenImp()
{
    /*
     State machine using the double-space convention:

       At line start:
        - Optional label (ident/% at column 0)
        - Skip spaces, optional dots (structured block levels)
        - Enter cmdMode

       In cmdMode:
        - Skip spaces
        - Read command keyword -> emit keyword token
        - Check what follows the keyword:
            a) ':' -> postcondition active; stay in argMode, set d_hasPostcond
            b) ' ' -> consume one space; peek next:
                - space or EOL -> argumentless (stay in cmdMode)
                - not space -> has args (enter argMode)
            c) EOL -> argumentless

       In argMode:
         - Tokenize expressions normally
         - When space hit:
           - If d_hasPostcond: consume one space; peek:
                - space -> argumentless (cmdMode), clear postcond
                - not space -> args follow, stay argMode, clear postcond
           - If !d_hasPostcond: end of args -> cmdMode

       Note: In argMode, identifiers are always Tok_ident (never keywords).
       Command keywords are ONLY recognized in cmdMode.
    */

    // NOTE: we cannot use tokenTypeFromString because too many irregulartities
    // -> watch out that tokens are handled if new operators are added!

    if( d_lineStart )
    {
        if( d_in.atEnd() )
            return token(Tok_Eof, 0);
        nextLine();
        d_lineStart = false;
        d_labelDone = false;
        d_cmdMode = false;
        d_hasPostcond = false;
        d_parenDepth = 0;

        if( d_line.trimmed().isEmpty() )
        {
            d_lineStart = true;
            d_colNr = d_line.size();
            return token(Tok_Newline, 0);
        }

        // label starts with alpha or % at col 0
        if( d_line.size() > 0 && (::isalpha((quint8)d_line[0]) || d_line[0] == '%') )
        {
            // ident() will return it
        }else
        {
            // No label; skip leading whitespace, enter command mode
            d_labelDone = true;
            while( lookAhead(0) == ' ' || lookAhead(0) == '\t' )
                d_colNr++;

            // Check for dot level indicators
            if( lookAhead(0) == '.' )
            {
                Token t = token(Tok_Dot, 1, ".");
                // skip space after dot
                if( lookAhead(0) == ' ' )
                    d_colNr++;
                d_cmdMode = true;
                return t;
            }

            d_cmdMode = true;
        }
    }

    // Past end of line; emit Newline
    if( d_colNr >= d_line.size() )
    {
        d_lineStart = true;
        return token(Tok_Newline, 0);
    }

    const char ch = (quint8)d_line[d_colNr];

    // Label handling (start of line, before commands)
    if( !d_labelDone )
    {
        if( ::isalpha((quint8)ch) || ch == '%' )
        {
            Token t = ident(); // emit label as Tok_ident
            // Check if label is followed by formal parameter list or we're inside one
            if( d_colNr < d_line.size() )
            {
                char nxt = d_line[d_colNr];
                if( nxt == '(' || nxt == ')' || nxt == ',' )
                {
                    // Start of params, inside params, or end of params
                    d_labelDone = false;
                    return t;
                }
            }
            d_labelDone = true;
            // Skip spaces after label
            while( lookAhead(0) == ' ' || lookAhead(0) == '\t' )
                d_colNr++;
            // Check for dot level indicators after label
            if( lookAhead(0) == '.' )
            {
                d_cmdMode = true;
                return t; // dots will be consumed next call
            }
            d_cmdMode = true;
            return t;
        }
        if( ch == '(' )
            return token(Tok_Lpar, 1, "(");
        if( ch == ')' )
        {
            Token t = token(Tok_Rpar, 1, ")");
            d_labelDone = true;
            // Skip spaces after closing paren of formal params
            while( lookAhead(0) == ' ' || lookAhead(0) == '\t' )
                d_colNr++;
            d_cmdMode = true;
            return t;
        }
        if( ch == ',' )
            return token(Tok_Comma, 1, ",");
        if( ch == ' ' || ch == '\t' )
        {
            // Label was empty or already consumed; skip spaces
            d_labelDone = true;
            while( lookAhead(0) == ' ' || lookAhead(0) == '\t' )
                d_colNr++;
            d_cmdMode = true;
            return nextTokenImp();
        }
        if( ch == ';' )
        {
            d_labelDone = true;
            return comment();
        }
    }

    if( d_cmdMode && ch == '.' )
    {
        Token t = token(Tok_Dot, 1, ".");
        if( lookAhead(0) == ' ' )
            d_colNr++;
        return t;
    }

    if( d_cmdMode )     // read command keyword
    {
        // Skip spaces
        if( ch == ' ' || ch == '\t' )
        {
            while( lookAhead(0) == ' ' || lookAhead(0) == '\t' )
                d_colNr++;
            if( d_colNr >= d_line.size() )
            {
                d_lineStart = true;
                return token(Tok_Newline, 0);
            }
            return nextTokenImp();
        }

        if( ch == ';' )
            return comment();

        if( ::isalpha((quint8)ch) )
        {
            int off = 0;
            while( d_colNr + off < d_line.size() && ::isalnum((quint8)d_line[d_colNr + off]) )
                off++;
            const QByteArray word = d_line.mid(d_colNr, off);
            TokenType tt = matchCommand(word);
            if( tt == Tok_Invalid )
            {
                // Unknown command word: treat rest of line as comment (handles .rou file headers, $TEXT data lines, etc.)
                d_colNr = d_line.size();
                d_lineStart = true;
                return token(Tok_Newline, 0);
            }

            Token t = token(tt, off, word);
            d_cmdMode = false;
            d_hasPostcond = false;

            // After command keyword: check what follows
            if( d_colNr >= d_line.size() )
            {
                // EOL -> argumentless
                d_cmdMode = true;
                return t;
            }

            const char next = d_line[d_colNr];
            if( next == ':' )
            {
                d_hasPostcond = true;
                // Don't consume ':'; parser will read it
            }else if( next == ' ' || next == '\t' )
            {
                // Space after command word: consume one space (mandatory ls)
                d_colNr++;

                // Double-space check: peek at next character
                if( d_colNr >= d_line.size() )
                {
                    // EOL after single space -> argumentless
                    d_cmdMode = true;
                }
                else if( d_line[d_colNr] == ' ' || d_line[d_colNr] == '\t' )
                {
                    // Double space -> argumentless command
                    d_cmdMode = true;
                    // Don't consume the second space; cmdMode will skip it
                }
                // else: single space, non-space follows, has arguments, stay in argMode
            }else
            {
                // Some other char immediately after keyword (shouldn't happen in standard MUMPS)
                // stay in argMode
            }
            return t;
        }

        // Non-alpha in command mode -> end of commands for this line
        d_lineStart = true;
        return token(Tok_Newline, 0);
    }

    // inside parentheses, spaces are insignificant (just skip them)
    // outside parentheses, spaces are command/argument boundaries
    if( ch == ' ' || ch == '\t' )
    {
        if( d_parenDepth > 0 )
        {
            d_colNr++;
            return nextTokenImp();
        }

        if( d_hasPostcond )
        {
            // end of postcondition expression.
            d_hasPostcond = false;
            // consume one space (the space after postcond)
            d_colNr++;

            // double-space check for arguments after postcondition
            if( d_colNr >= d_line.size() )
            {
                // argumentless after postcond
                d_cmdMode = true;
            }else if( d_line[d_colNr] == ' ' || d_line[d_colNr] == '\t' )
            {
                // argumentless, next command follows
                d_cmdMode = true;
            } // else: single space, non-space follows -> arguments follow

            // Emit CmdSep to separate postcondition from arguments
            return token(Tok_CmdSep, 0);
        }else
        {
            // End of arguments -> next command
            d_colNr++; // consume the space
            d_cmdMode = true;

            // Peek ahead: if no valid command follows, don't emit CmdSep
            int peekPos = d_colNr;
            while( peekPos < d_line.size() && (d_line[peekPos] == ' ' || d_line[peekPos] == '\t') )
                peekPos++;
            if( peekPos >= d_line.size() || d_line[peekPos] == ';' || d_line[peekPos] == '.' )
                return nextTokenImp();
            if( !::isalpha((quint8)d_line[peekPos]) )
                return nextTokenImp();
            // Read the word and check if it's a valid command
            int wordStart = peekPos;
            while( peekPos < d_line.size() && ::isalnum((quint8)d_line[peekPos]) )
                peekPos++;
            const QByteArray word = d_line.mid(wordStart, peekPos - wordStart);
            if( matchCommand(word) == Tok_Invalid )
                // Not a valid command; treat rest of line as non-code
                return nextTokenImp();

            // Emit CmdSep to stop expressions at space boundary
            return token(Tok_CmdSep, 0);
        }
    }

    if( ch == ';' )
        return comment();

    if( ch == '"' )
        return string();

    if( ::isdigit((quint8)ch) )
        return number();
    // leading dot followed by digit?
    if( ch == '.' && d_colNr + 1 < d_line.size() && ::isdigit((quint8)d_line[d_colNr + 1]) )
        return number();

    if( ::isalpha((quint8)ch) || ch == '%' )
        return ident();

    switch( ch )
    {
    case '+':
        return token(Tok_Plus, 1, "+");
    case '-':
        return token(Tok_Minus, 1, "-");
    case '*':
        return token(Tok_Star, 1, "*");
    case '/':
        return token(Tok_Slash, 1, "/");
    case '\\':
        return token(Tok_bslash, 1, "\\");
    case '#':
        return token(Tok_Hash, 1, "#");
    case '_':
        return token(Tok_5f, 1, "_");
    case '&':
        return token(Tok_Amp, 1, "&");
    case '!':
        return token(Tok_Bang, 1, "!");
    case '<':
        return token(Tok_Lt, 1, "<");
    case '>':
        return token(Tok_Gt, 1, ">");
    case '=':
        return token(Tok_Eq, 1, "=");
    case '?':
        return token(Tok_Qmark, 1, "?");
    case '[': {
        // Check if this is an extended reference context: ^ident[UCI,VOL]
        // If previous tokens were ^ident, skip the bracket content
        if( d_lastToken.d_type == Tok_ident && d_prevToken.d_type == Tok_Hat )
        {
            int depth = 1;
            d_colNr++; // skip [
            while( d_colNr < d_line.size() && depth > 0 )
            {
                char c = d_line[d_colNr];
                d_colNr++;
                if( c == '[' )
                    depth++;
                else if( c == ']' )
                    depth--;
                else if( c == '"' ) {
                    while( d_colNr < d_line.size() ) {
                        if( d_line[d_colNr] == '"' ) {
                            d_colNr++;
                            if( d_colNr >= d_line.size() || d_line[d_colNr] != '"')
                                break;
                        }
                        d_colNr++;
                    }
                }
            }
            return nextTokenImp();
        }
        return token(Tok_Lbrack, 1, "[");
    }
    case ']':
        return token(Tok_Rbrack, 1, "]");
    case '(':
        d_parenDepth++;
        return token(Tok_Lpar, 1, "(");
    case ')':
        if(d_parenDepth > 0)
            d_parenDepth--;
        return token(Tok_Rpar, 1, ")");
    case ',':
        return token(Tok_Comma, 1, ",");
    case ':':
        return token(Tok_Colon, 1, ":");
    case '^': {
        // Check for extended global reference: ^[UCI,VOL]name
        // Skip the [...] part and just emit ^name
        Token hat = token(Tok_Hat, 1, "^");
        if( lookAhead(0) == '[' )
        {
            // Skip everything up to and including ']'
            int depth = 0;
            while( d_colNr < d_line.size() )
            {
                char c = d_line[d_colNr];
                d_colNr++;
                if( c == '[' )
                    depth++;
                else if( c == ']' ) {
                    depth--;
                    if(depth <= 0)
                        break;
                }else if( c == '"' ) {
                    // skip string literals inside brackets
                    while( d_colNr < d_line.size() ) {
                        if( d_line[d_colNr] == '"' ) {
                            d_colNr++;
                            if( d_colNr >= d_line.size() || d_line[d_colNr] != '"')
                                break;
                            d_colNr++;
                        }else
                            d_colNr++;
                    }
                }
            }
            // Skip optional space after ]
            while( lookAhead(0) == ' ' || lookAhead(0) == '\t' )
                d_colNr++;
        }
        return hat;
    }
    case '$':
        if( lookAhead(1) == '$' )
            return token(Tok_2Dlr, 2, "$$");
        return token(Tok_Dlr, 1, "$");
    case '@':
        return token(Tok_At, 1, "@");
    case '.':
        return token(Tok_Dot, 1, ".");
    case '\'':
        return token(Tok_tick, 1, "'");
    default:
        return token(Tok_Invalid, 1,
                     QString("unexpected character '%1' (%2)").arg(ch).arg(int((quint8)ch)).toUtf8());
    }
}

Token Lexer::ident()
{
    int off = 0;
    if( lookAhead(0) == '%' )
        off = 1;
    while( d_colNr + off < d_line.size() && ::isalnum((quint8)d_line[d_colNr + off]) )
        off++;
    if( off == 0 )
        return token(Tok_Invalid, 1, "expected identifier");
    const QByteArray str = d_line.mid(d_colNr, off);
    return token(Tok_ident, off, str);
}

Token Lexer::number()
{
    int off = 0;
    bool isReal = false;

    while( d_colNr + off < d_line.size() && ::isdigit((quint8)d_line[d_colNr + off]) )
        off++;

    if( d_colNr + off < d_line.size() && d_line[d_colNr + off] == '.' )
    {
        isReal = true;
        off++;
        while( d_colNr + off < d_line.size() && ::isdigit((quint8)d_line[d_colNr + off]) )
            off++;
    }

    if( d_colNr + off < d_line.size() && (d_line[d_colNr + off] == 'E' || d_line[d_colNr + off] == 'e') )
    {
        int eoff = off + 1;
        if( d_colNr + eoff < d_line.size() &&
            (d_line[d_colNr + eoff] == '+' || d_line[d_colNr + eoff] == '-') )
            eoff++;
        if( d_colNr + eoff < d_line.size() && ::isdigit((quint8)d_line[d_colNr + eoff]) )
        {
            isReal = true;
            off = eoff;
            while( d_colNr + off < d_line.size() && ::isdigit((quint8)d_line[d_colNr + off]) )
                off++;
        }
    }

    const QByteArray str = d_line.mid(d_colNr, off);
    return token(isReal ? Tok_real : Tok_integer, off, str);
}

Token Lexer::string()
{
    int off = 1; // skip opening "
    while( d_colNr + off < d_line.size() )
    {
        const char c = d_line[d_colNr + off];
        off++;
        if( c == '"' )
        {
            if( d_colNr + off < d_line.size() && d_line[d_colNr + off] == '"' )
                off++; // escaped quote ""
            else
                break; // end of string
        }
    }
    const QByteArray str = d_line.mid(d_colNr, off);
    return token(Tok_string, off, str);
}

Token Lexer::comment()
{
    const int len = d_line.size() - d_colNr;
    const QByteArray str = d_line.mid(d_colNr, len);
    Token t = token(Tok_Comment, len, str);
    return t;
}
