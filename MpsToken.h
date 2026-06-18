#ifndef MPSTOKEN_H
#define MPSTOKEN_H

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

#include <QString>
#include <QByteArray>
#include <Mumps/MpsTokenType.h>

namespace Mps {

struct Token {
    quint16 d_type; // TokenType
    quint32 d_lineNr;
    quint16 d_colNr;
    quint16 d_len;
    QByteArray d_val;
    QString d_sourcePath;

    Token(quint16 t = Tok_Invalid, quint32 line = 0, quint16 col = 0, quint16 len = 0,
          const QByteArray& val = QByteArray())
        : d_type(t), d_lineNr(line), d_colNr(col), d_len(len), d_val(val) {}

    bool isValid() const { return d_type != Tok_Invalid && d_type != Tok_Eof; }
    bool isEof() const { return d_type == Tok_Eof; }
};

}

#endif // MPSTOKEN_H
