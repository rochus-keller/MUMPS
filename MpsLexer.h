#ifndef MPSLEXER_H
#define MPSLEXER_H

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


#include <QBuffer>
#include "MpsToken.h"

namespace Mps {

class Lexer {
public:
    Lexer();

    void setStream(QIODevice*, const QString& sourcePath = QString());
    void setStream(const QByteArray&, const QString& sourcePath = QString());
    bool setStream(const QString& sourcePath);

    void setIgnoreComments(bool b) { d_ignoreComments = b; }

    Token nextToken();
    Token peekToken(quint8 lookAhead = 1);

    quint32 getSloc() const { return d_sloc; }

protected:
    Token nextTokenImp();
    void nextLine();
    int lookAhead(int off = 1) const;
    Token token(TokenType tt, int len = 1, const QByteArray& val = QByteArray());
    Token ident();
    Token number();
    Token string();
    Token comment();
    void countLine();

    static TokenType matchCommand(const QByteArray& word);

private:
    QBuffer d_in;
    quint32 d_sloc;
    quint32 d_lineNr;
    quint16 d_colNr;
    QString d_sourcePath;
    QByteArray d_line;
    QList<Token> d_buffer;
    Token d_lastToken;
    Token d_prevToken;  // token before d_lastToken (for bracket context)
    bool d_ignoreComments;
    bool d_lineCounted;

    bool d_cmdMode;       // next identifier should be checked as command keyword
    bool d_lineStart;     // at beginning of a new line (label possible)
    bool d_labelDone;     // label already processed for this line
    bool d_hasPostcond;   // postcondition active; next space = postcond/args boundary
    int d_parenDepth;     // nesting depth of ( ), suppress CmdSep inside parens
};

}

#endif // MPSLEXER_H
