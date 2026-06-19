#ifndef MPSPARSER2_H
#define MPSPARSER2_H

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

// AST-building parser for MUMPS-76.
// Based on the generated MpsParser (EbnfStudio) with procedures modified
// to construct AST nodes (MpsAst.h) instead of returning void.
// The lexer (MpsLexer) is reused unchanged.

#include "MpsParser.h"
#include "MpsAst.h"

namespace Mps {

class Parser2 {
public:
    Parser2(Scanner* s) : scanner(s) {}

    Routine* parse();

    struct Error {
        QString msg;
        int row, col;
        QString path;
        Error( const QString& m, int r, int c, const QString& p)
            : msg(m), row(r), col(c), path(p) {}
    };
    QList<Error> errors;

protected:
    // Line-level
    Line* line();

    // Commands
    Command* command();
    Command* break_();
    Command* close_();
    Command* do_();
    Command* else_();
    Command* for_();
    Command* goto_();
    Command* halt_();
    Command* if_();
    Command* kill_();
    Command* lock_();
    Command* open_();
    Command* quit_();
    Command* read_();
    Command* set_();
    Command* use_();
    Command* view_();
    Command* write_();
    Command* xecute_();
    Command* new_();
    Command* job_();
    Command* zcmd_();

    // Postcondition
    Expression* postcond();

    // Expressions
    Expression* expr();
    ExprAtom* expratom();
    ExprAtom* numlit();
    ExprAtom* dollaritem();
    ExprAtom* gvntail();
    void exprlist(QList<Expression*>& list);
    void funcargs(QList<Expression*>& args);

    // Pattern matching
    Pattern* pattern();
    PatElem* patAtom();

    // Variable references
    VarRef* glvn();
    VarRef* lvar();
    VarRef* setdest();
    VarRef* nref();
    VarRef* killarg();

    // Entry references
    EntryRef* entryref();
    void actuallist(QList<Expression*>& list, QList<bool>& byRef);

    // Device / open params
    void openargs(QList<DeviceArg*>& args);
    DeviceArg* openarg();
    void openparams(QList<Expression*>& params);
    void openparam(QList<Expression*>& params);

    // Token handling (identical to generated Parser)
    Token cur;
    Token la;
    Scanner* scanner;
    void next();
    Token peek(int off);
    void invalid(const char* what);
    bool expect(int tt, bool pkw, const char* where);
};

}

#endif // MPSPARSER2_H
