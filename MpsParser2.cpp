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

#include "MpsParser2.h"
#include <Mumps/MpsTokenType.h>
using namespace Mps;


static inline bool FIRST_command(int tt) {
    switch(tt){
    case Tok_BREAK: case Tok_CLOSE:
    case Tok_DO: case Tok_ELSE:
    case Tok_FOR: case Tok_GOTO:
    case Tok_HALT: case Tok_IF:
    case Tok_JOB: case Tok_KILL:
    case Tok_LOCK: case Tok_NEW:
    case Tok_OPEN: case Tok_QUIT:
    case Tok_READ: case Tok_SET:
    case Tok_USE: case Tok_VIEW:
    case Tok_WRITE: case Tok_XECUTE:
    case Tok_ZCMD:
        return true;
    default: return false;
    }
}

static inline bool FIRST_line(int tt) {
    switch(tt){
    case Tok_CmdSep: case Tok_Dot: case Tok_Newline: case Tok_ident:
        return true;
    default: return FIRST_command(tt);
    }
}

static inline bool FIRST_label(int tt) {
    return tt == Tok_ident;
}

static inline bool FIRST_postcond(int tt) {
    return tt == Tok_Colon;
}

static inline bool FIRST_expr(int tt) {
    switch(tt){
    case Tok_2Dlr: case Tok_At:
    case Tok_Dlr: case Tok_Hat:
    case Tok_Lpar: case Tok_Minus:
    case Tok_Plus: case Tok_ident:
    case Tok_integer: case Tok_real:
    case Tok_string: case Tok_tick:
        return true;
    default: return false;
    }
}

static inline bool FIRST_expratom(int tt) {
    return FIRST_expr(tt);
}

static inline bool FIRST_exprlist(int tt) {
    switch(tt){
    case Tok_2Dlr: case Tok_At: case Tok_Dlr: case Tok_Dot:
    case Tok_Hat: case Tok_Lpar: case Tok_Minus: case Tok_Plus:
    case Tok_ident: case Tok_integer: case Tok_real: case Tok_string:
    case Tok_tick:
        return true;
    default: return false;
    }
}

static inline bool FIRST_numlit(int tt) {
    return tt == Tok_integer || tt == Tok_real;
}

static inline bool FIRST_dollaritem(int tt) {
    return tt == Tok_2Dlr || tt == Tok_Dlr;
}

static inline bool FIRST_gvntail(int tt) {
    return tt == Tok_At || tt == Tok_Lpar || tt == Tok_ident;
}

static inline bool FIRST_unaryop(int tt) {
    return tt == Tok_Minus || tt == Tok_Plus || tt == Tok_tick;
}

static inline bool FIRST_binop(int tt) {
    switch(tt){
    case Tok_5f: case Tok_Amp: case Tok_Bang: case Tok_Eq:
    case Tok_Gt: case Tok_Hash: case Tok_Lbrack: case Tok_Lt:
    case Tok_Minus: case Tok_Plus: case Tok_Rbrack: case Tok_Slash:
    case Tok_Star: case Tok_bslash:
        return true;
    default: return false;
    }
}

static inline bool FIRST_pattern(int tt) {
    switch(tt){
    case Tok_At: case Tok_Dot: case Tok_Lpar: case Tok_ident:
    case Tok_integer: case Tok_real: case Tok_string:
        return true;
    default: return false;
    }
}

static inline bool FIRST_funcarg(int tt) {
    return FIRST_expr(tt);
}

static inline bool FIRST_doargs(int tt) {
    return tt == Tok_At || tt == Tok_Hat || tt == Tok_ident || tt == Tok_integer;
}

static inline bool FIRST_forargs(int tt) {
    return tt == Tok_At || tt == Tok_ident;
}

static inline bool FIRST_glvn(int tt) {
    return tt == Tok_At || tt == Tok_Hat || tt == Tok_ident;
}

static inline bool FIRST_killargs(int tt) {
    return tt == Tok_At || tt == Tok_Dlr || tt == Tok_Hat || tt == Tok_Lpar || tt == Tok_ident;
}

static inline bool FIRST_lockargs(int tt) {
    return tt == Tok_At || tt == Tok_Hat || tt == Tok_Lpar || tt == Tok_ident;
}

static inline bool FIRST_openparams(int tt) {
    return tt == Tok_Colon;
}

static inline bool FIRST_readargs(int tt) {
    switch(tt){
    case Tok_At: case Tok_Bang: case Tok_Hash: case Tok_Hat:
    case Tok_Qmark: case Tok_Star: case Tok_ident: case Tok_string:
        return true;
    default: return false;
    }
}

static inline bool FIRST_readarg(int tt) {
    return FIRST_readargs(tt);
}

static inline bool FIRST_readfmt(int tt) {
    return tt == Tok_Bang || tt == Tok_Hash || tt == Tok_Qmark || tt == Tok_Star;
}

static inline bool FIRST_readvar(int tt) {
    return tt == Tok_At || tt == Tok_Hat || tt == Tok_ident;
}

static inline bool FIRST_setargs(int tt) {
    switch(tt){
    case Tok_At: case Tok_Dlr: case Tok_Eq: case Tok_Hat:
    case Tok_Lpar: case Tok_ident:
        return true;
    default: return false;
    }
}

static inline bool FIRST_setdest(int tt) {
    return tt == Tok_At || tt == Tok_Dlr || tt == Tok_Hat || tt == Tok_Lpar || tt == Tok_ident;
}

static inline bool FIRST_writeargs(int tt) {
    switch(tt){
    case Tok_2Dlr: case Tok_At: case Tok_Bang: case Tok_Dlr:
    case Tok_Hash: case Tok_Hat: case Tok_Lpar: case Tok_Minus:
    case Tok_Plus: case Tok_Qmark: case Tok_Star: case Tok_ident:
    case Tok_integer: case Tok_real: case Tok_string: case Tok_tick:
        return true;
    default: return false;
    }
}

static inline bool FIRST_writearg(int tt) {
    return FIRST_writeargs(tt);
}

static inline bool FIRST_useargs(int tt) {
    return FIRST_expr(tt);
}

static inline bool FIRST_xecuteargs(int tt) {
    return FIRST_expr(tt);
}

static inline bool FIRST_newargs(int tt) {
    return tt == Tok_Lpar || tt == Tok_ident;
}

static inline bool FIRST_viewargs(int tt) {
    switch(tt){
    case Tok_2Dlr: case Tok_At: case Tok_Colon: case Tok_Comma:
    case Tok_Dlr: case Tok_Hat: case Tok_Lpar: case Tok_Minus:
    case Tok_Plus: case Tok_ident: case Tok_integer: case Tok_real:
    case Tok_string: case Tok_tick:
        return true;
    default: return false;
    }
}

static inline bool FIRST_zargs(int tt) {
    switch(tt){
    case Tok_2Dlr: case Tok_At: case Tok_Dlr: case Tok_Hat:
    case Tok_Lpar: case Tok_Minus: case Tok_Plus: case Tok_ident:
    case Tok_integer: case Tok_real: case Tok_string: case Tok_tick:
        return true;
    default: return false;
    }
}

static inline bool FIRST_entryref(int tt) {
    return tt == Tok_At || tt == Tok_Hat || tt == Tok_ident || tt == Tok_integer;
}

static inline bool FIRST_label_ref(int tt) {
    return tt == Tok_ident || tt == Tok_integer;
}

static inline bool FIRST_actuallist(int tt) {
    switch(tt){
    case Tok_2Dlr: case Tok_At: case Tok_Dlr: case Tok_Dot:
    case Tok_Hat: case Tok_Lpar: case Tok_Minus: case Tok_Plus:
    case Tok_ident: case Tok_integer: case Tok_real: case Tok_string:
    case Tok_tick:
        return true;
    default: return false;
    }
}


void Parser2::next()
{
    cur = la;
    if( !d_queue.isEmpty() )
    {
        la = d_queue.takeFirst();
        return;
    }
    la = scanner->next();
    while( la.d_type == Tok_Invalid )
    {
        errors << Error(la.d_val, la.d_lineNr, la.d_colNr, la.d_sourcePath);
        la = scanner->next();
    }
}

Token Parser2::peek(int off)
{
    if( off == 1 )
        return la;
    else if( off == 0 )
        return cur;
    else
        return scanner->peek(off-1);
}

void Parser2::invalid(const char* what)
{
    errors << Error(QString("invalid %1").arg(what),
                    la.d_lineNr, la.d_colNr, la.d_sourcePath);
}

bool Parser2::expect(int tt, bool pkw, const char* where)
{
    Q_UNUSED(pkw);
    if( la.d_type == tt )
    {
        next();
        return true;
    }else
    {
        errors << Error(QString("'%1' expected in %2").arg(tokenTypeString(tt)).arg(where),
                        la.d_lineNr, la.d_colNr, la.d_sourcePath);
        return false;
    }
}


Routine* Parser2::parse()
{
    errors.clear();
    next();

    Routine* r = new Routine();
    r->d_sourcePath = la.d_sourcePath;

    while( FIRST_line(la.d_type) )
    {
        Line* l = line();
        if( l )
            r->d_lines.append(l);
    }
    return r;
}

Line* Parser2::line()
{
    Line* l = new Line();
    l->d_lineNr = la.d_lineNr;

    // Optional label
    if( FIRST_label(la.d_type) )
    {
        l->d_label = la.d_val;
        expect(Tok_ident, false, "label");

        // Optional formal params: label(p1,p2,...)
        if( la.d_type == Tok_Lpar )
        {
            expect(Tok_Lpar, false, "label");
            if( FIRST_expr(la.d_type) )
            {
                // params are syntactically expressions, but semantically idents
                Expression* e = expr();
                if( e && !e->d_operands.isEmpty()
                    && e->d_operands.first()->d_tag == ExprAtom::LocalVar
                    && e->d_ops.isEmpty() )
                    l->d_params.append(e->d_operands.first()->d_name);
                else if( e && !e->d_operands.isEmpty() )
                    l->d_params.append(e->d_operands.first()->d_val);
                delete e;

                while( la.d_type == Tok_Comma )
                {
                    expect(Tok_Comma, false, "params");
                    e = expr();
                    if( e && !e->d_operands.isEmpty()
                        && e->d_operands.first()->d_tag == ExprAtom::LocalVar
                        && e->d_ops.isEmpty() )
                        l->d_params.append(e->d_operands.first()->d_name);
                    else if( e && !e->d_operands.isEmpty() )
                        l->d_params.append(e->d_operands.first()->d_val);
                    delete e;
                }
            }
            expect(Tok_Rpar, false, "label");
        }
    }

    // Dot level
    while( la.d_type == Tok_Dot )
    {
        l->d_dotLevel++;
        expect(Tok_Dot, false, "line");
    }

    // Commands
    while( la.d_type == Tok_CmdSep || FIRST_command(la.d_type) )
    {
        if( la.d_type == Tok_CmdSep )
            expect(Tok_CmdSep, false, "line");
        Command* c = command();
        if( c )
            l->d_commands.append(c);
    }

    expect(Tok_Newline, false, "line");
    return l;
}

Command* Parser2::command()
{
    if( la.d_type == Tok_BREAK )
        return break_();
    if( la.d_type == Tok_CLOSE )
        return close_();
    if( la.d_type == Tok_DO )
        return do_();
    if( la.d_type == Tok_ELSE )
        return else_();
    if( la.d_type == Tok_FOR )
        return for_();
    if( la.d_type == Tok_GOTO )
        return goto_();
    if( la.d_type == Tok_HALT )
        return halt_();
    if( la.d_type == Tok_IF )
        return if_();
    if( la.d_type == Tok_KILL )
        return kill_();
    if( la.d_type == Tok_LOCK )
        return lock_();
    if( la.d_type == Tok_OPEN )
        return open_();
    if( la.d_type == Tok_QUIT )
        return quit_();
    if( la.d_type == Tok_READ )
        return read_();
    if( la.d_type == Tok_SET )
        return set_();
    if( la.d_type == Tok_USE )
        return use_();
    if( la.d_type == Tok_VIEW )
        return view_();
    if( la.d_type == Tok_WRITE )
        return write_();
    if( la.d_type == Tok_XECUTE )
        return xecute_();
    if( la.d_type == Tok_NEW )
        return new_();
    if( la.d_type == Tok_JOB )
        return job_();
    if( la.d_type == Tok_ZCMD )
        return zcmd_();
    invalid("command");
    return 0;
}


Expression* Parser2::postcond()
{
    expect(Tok_Colon, false, "postcond");
    return expr();
}

// Helper macro for the common command prologue:
// consume keyword, parse optional postcond, consume optional CmdSep
#define CMD_PROLOGUE(tokType, cmdName) \
    Command* c = new Command(); \
    c->d_lineNr = la.d_lineNr; \
    c->d_colNr = la.d_colNr; \
    c->d_type = tokType; \
    expect(tokType, false, cmdName); \
    if( FIRST_postcond(la.d_type) ) \
        c->d_postcond = postcond(); \
    if( la.d_type == Tok_CmdSep ) \
        expect(Tok_CmdSep, false, cmdName)

Command* Parser2::break_()
{
    CMD_PROLOGUE(Tok_BREAK, "break_");
    if( FIRST_exprlist(la.d_type) )
        exprlist(c->d_exprs);
    return c;
}

Command* Parser2::close_()
{
    CMD_PROLOGUE(Tok_CLOSE, "close_");
    openargs(c->d_deviceArgs);
    return c;
}

Command* Parser2::do_()
{
    CMD_PROLOGUE(Tok_DO, "do_");
    if( FIRST_doargs(la.d_type) )
    {
        // doargs: doarg { ',' doarg }
        CondEntry* ce = new CondEntry();
        ce->d_entry = entryref();
        if( FIRST_postcond(la.d_type) )
            ce->d_postcond = postcond();
        c->d_entries.append(ce);

        while( la.d_type == Tok_Comma )
        {
            expect(Tok_Comma, false, "doargs");
            ce = new CondEntry();
            ce->d_entry = entryref();
            if( FIRST_postcond(la.d_type) )
                ce->d_postcond = postcond();
            c->d_entries.append(ce);
        }
    }
    return c;
}

Command* Parser2::else_()
{
    Command* c = new Command();
    c->d_lineNr = la.d_lineNr;
    c->d_colNr = la.d_colNr;
    c->d_type = Tok_ELSE;
    expect(Tok_ELSE, false, "else_");
    return c;
}

Command* Parser2::for_()
{
    CMD_PROLOGUE(Tok_FOR, "for_");
    if( FIRST_forargs(la.d_type) )
    {
        // forargs: lvar '=' forarg { ',' forarg }
        c->d_forVar = lvar();
        expect(Tok_Eq, false, "forargs");

        // forarg: expr [ ':' expr [ ':' expr ] ]
        ForRange* fr = new ForRange();
        fr->d_start = expr();
        if( la.d_type == Tok_Colon )
        {
            expect(Tok_Colon, false, "forarg");
            fr->d_increment = expr();
            if( la.d_type == Tok_Colon )
            {
                expect(Tok_Colon, false, "forarg");
                fr->d_limit = expr();
            }
        }
        c->d_forRanges.append(fr);

        while( la.d_type == Tok_Comma )
        {
            expect(Tok_Comma, false, "forargs");
            fr = new ForRange();
            fr->d_start = expr();
            if( la.d_type == Tok_Colon )
            {
                expect(Tok_Colon, false, "forarg");
                fr->d_increment = expr();
                if( la.d_type == Tok_Colon )
                {
                    expect(Tok_Colon, false, "forarg");
                    fr->d_limit = expr();
                }
            }
            c->d_forRanges.append(fr);
        }
    }
    return c;
}

Command* Parser2::goto_()
{
    CMD_PROLOGUE(Tok_GOTO, "goto_");
    // gotoargs: gotoarg { ',' gotoarg }
    CondEntry* ce = new CondEntry();
    ce->d_entry = entryref();
    if( FIRST_postcond(la.d_type) )
        ce->d_postcond = postcond();
    c->d_entries.append(ce);

    while( la.d_type == Tok_Comma )
    {
        expect(Tok_Comma, false, "gotoargs");
        ce = new CondEntry();
        ce->d_entry = entryref();
        if( FIRST_postcond(la.d_type) )
            ce->d_postcond = postcond();
        c->d_entries.append(ce);
    }
    return c;
}

Command* Parser2::halt_()
{
    CMD_PROLOGUE(Tok_HALT, "halt_");
    if( FIRST_exprlist(la.d_type) )
        exprlist(c->d_exprs);
    return c;
}

Command* Parser2::if_()
{
    CMD_PROLOGUE(Tok_IF, "if_");
    if( FIRST_exprlist(la.d_type) )
        exprlist(c->d_exprs);
    return c;
}

Command* Parser2::kill_()
{
    CMD_PROLOGUE(Tok_KILL, "kill_");
    if( FIRST_killargs(la.d_type) )
    {
        c->d_killArgs.append(killarg());
        while( la.d_type == Tok_Comma )
        {
            expect(Tok_Comma, false, "killargs");
            c->d_killArgs.append(killarg());
        }
    }
    return c;
}

Command* Parser2::lock_()
{
    CMD_PROLOGUE(Tok_LOCK, "lock_");
    if( FIRST_lockargs(la.d_type) )
    {
        // lockarg: nref [ ':' expr ]
        LockArg* la2 = new LockArg();
        la2->d_ref = nref();
        if( la.d_type == Tok_Colon )
        {
            expect(Tok_Colon, false, "lockarg");
            la2->d_timeout = expr();
        }
        c->d_lockArgs.append(la2);

        while( la.d_type == Tok_Comma )
        {
            expect(Tok_Comma, false, "lockargs");
            la2 = new LockArg();
            la2->d_ref = nref();
            if( la.d_type == Tok_Colon )
            {
                expect(Tok_Colon, false, "lockarg");
                la2->d_timeout = expr();
            }
            c->d_lockArgs.append(la2);
        }
    }
    return c;
}

Command* Parser2::open_()
{
    CMD_PROLOGUE(Tok_OPEN, "open_");
    openargs(c->d_deviceArgs);
    return c;
}

Command* Parser2::quit_()
{
    CMD_PROLOGUE(Tok_QUIT, "quit_");
    if( FIRST_expr(la.d_type) )
        c->d_quitExpr = expr();
    return c;
}

Command* Parser2::read_()
{
    CMD_PROLOGUE(Tok_READ, "read_");
    // readargs: readarg { [','] readarg }
    if( FIRST_readarg(la.d_type) )
    {
        // readarg: readfmt | string | readvar
        if( FIRST_readfmt(la.d_type) )
        {
            ReadArg* ra = new ReadArg();
            if( la.d_type == Tok_Bang )
            {
                ra->d_kind = ReadArg::NewLine;
                expect(Tok_Bang, false, "readfmt");
            }else if( la.d_type == Tok_Hash )
            {
                ra->d_kind = ReadArg::FormFeed;
                expect(Tok_Hash, false, "readfmt");
            }else if( la.d_type == Tok_Qmark )
            {
                ra->d_kind = ReadArg::Tab;
                expect(Tok_Qmark, false, "readfmt");
                ra->d_expr = expr();
            } else if( la.d_type == Tok_Star )
            {
                ra->d_kind = ReadArg::Star;
                expect(Tok_Star, false, "readfmt");
                ra->d_var = glvn();
                if( la.d_type == Tok_Colon )
                {
                    expect(Tok_Colon, false, "readfmt");
                    ra->d_timeout = expr();
                }
            }
            c->d_readArgs.append(ra);
        }
        else if( la.d_type == Tok_string )
        {
            ReadArg* ra = new ReadArg();
            ra->d_kind = ReadArg::Prompt;
            ra->d_expr = new Expression();
            ra->d_expr->d_lineNr = la.d_lineNr;
            ra->d_expr->d_colNr = la.d_colNr;
            ExprAtom* a = new ExprAtom();
            a->d_tag = ExprAtom::StringLit;
            a->d_val = la.d_val;
            a->d_lineNr = la.d_lineNr;
            a->d_colNr = la.d_colNr;
            ra->d_expr->d_operands.append(a);
            expect(Tok_string, false, "readarg");
            c->d_readArgs.append(ra);
        }else if( FIRST_readvar(la.d_type) )
        {
            ReadArg* ra = new ReadArg();
            ra->d_kind = ReadArg::Var;
            ra->d_var = glvn();
            if( la.d_type == Tok_Hash )
            {
                expect(Tok_Hash, false, "readvar");
                ra->d_maxLen = expr();
            }
            if( la.d_type == Tok_Colon )
            {
                expect(Tok_Colon, false, "readvar");
                ra->d_timeout = expr();
            }
            c->d_readArgs.append(ra);
        }else
            invalid("readarg");

        // Remaining readargs: { [','] readarg }
        while( la.d_type == Tok_Comma || FIRST_readarg(la.d_type) )
        {
            if( la.d_type == Tok_Comma )
                expect(Tok_Comma, false, "readargs");

            if( FIRST_readfmt(la.d_type) )
            {
                ReadArg* ra = new ReadArg();
                if( la.d_type == Tok_Bang )
                {
                    ra->d_kind = ReadArg::NewLine;
                    expect(Tok_Bang, false, "readfmt");
                } else if( la.d_type == Tok_Hash )
                {
                    ra->d_kind = ReadArg::FormFeed;
                    expect(Tok_Hash, false, "readfmt");
                } else if( la.d_type == Tok_Qmark )
                {
                    ra->d_kind = ReadArg::Tab;
                    expect(Tok_Qmark, false, "readfmt");
                    ra->d_expr = expr();
                }else if( la.d_type == Tok_Star )
                {
                    ra->d_kind = ReadArg::Star;
                    expect(Tok_Star, false, "readfmt");
                    ra->d_var = glvn();
                    if( la.d_type == Tok_Colon )
                    {
                        expect(Tok_Colon, false, "readfmt");
                        ra->d_timeout = expr();
                    }
                }
                c->d_readArgs.append(ra);
            }else if( la.d_type == Tok_string )
            {
                ReadArg* ra = new ReadArg();
                ra->d_kind = ReadArg::Prompt;
                ra->d_expr = new Expression();
                ra->d_expr->d_lineNr = la.d_lineNr;
                ra->d_expr->d_colNr = la.d_colNr;
                ExprAtom* a = new ExprAtom();
                a->d_tag = ExprAtom::StringLit;
                a->d_val = la.d_val;
                a->d_lineNr = la.d_lineNr;
                a->d_colNr = la.d_colNr;
                ra->d_expr->d_operands.append(a);
                expect(Tok_string, false, "readarg");
                c->d_readArgs.append(ra);
            } else if( FIRST_readvar(la.d_type) )
            {
                ReadArg* ra = new ReadArg();
                ra->d_kind = ReadArg::Var;
                ra->d_var = glvn();
                if( la.d_type == Tok_Hash )
                {
                    expect(Tok_Hash, false, "readvar");
                    ra->d_maxLen = expr();
                }
                if( la.d_type == Tok_Colon )
                {
                    expect(Tok_Colon, false, "readvar");
                    ra->d_timeout = expr();
                }
                c->d_readArgs.append(ra);
            }else
            {
                invalid("readarg");
                break;
            }
        }
    }
    return c;
}

Command* Parser2::set_()
{
    CMD_PROLOGUE(Tok_SET, "set_");
    // setargs: setarg { ',' setarg }
    // setarg: setdest [ '=' expr ] | '='
    {
        SetArg* sa = new SetArg();
        if( FIRST_setdest(la.d_type) )
        {
            sa->d_dests.append(setdest());
            if( la.d_type == Tok_Eq )
            {
                expect(Tok_Eq, false, "setarg");
                sa->d_expr = expr();
            }
        }
        else if( la.d_type == Tok_Eq )
            expect(Tok_Eq, false, "setarg");
        else
            invalid("setarg");
        c->d_setArgs.append(sa);
    }

    while( la.d_type == Tok_Comma )
    {
        expect(Tok_Comma, false, "setargs");
        SetArg* sa = new SetArg();
        if( FIRST_setdest(la.d_type) )
        {
            sa->d_dests.append(setdest());
            if( la.d_type == Tok_Eq )
            {
                expect(Tok_Eq, false, "setarg");
                sa->d_expr = expr();
            }
        }else if( la.d_type == Tok_Eq )
            expect(Tok_Eq, false, "setarg");
        else
            invalid("setarg");
        c->d_setArgs.append(sa);
    }
    return c;
}

Command* Parser2::use_()
{
    CMD_PROLOGUE(Tok_USE, "use_");
    if( FIRST_useargs(la.d_type) )
    {
        // usearg: expr [openparams]
        DeviceArg* da = new DeviceArg();
        da->d_expr = expr();
        if( FIRST_openparams(la.d_type) )
            openparams(da->d_params);
        c->d_deviceArgs.append(da);

        while( la.d_type == Tok_Comma )
        {
            expect(Tok_Comma, false, "useargs");
            da = new DeviceArg();
            da->d_expr = expr();
            if( FIRST_openparams(la.d_type) )
                openparams(da->d_params);
            c->d_deviceArgs.append(da);
        }
    }
    return c;
}

Command* Parser2::view_()
{
    CMD_PROLOGUE(Tok_VIEW, "view_");
    if( FIRST_viewargs(la.d_type) )
    {
        // viewgroup: [expr] { ':' [expr] }
        ViewGroup* vg = new ViewGroup();
        if( FIRST_expr(la.d_type) )
            vg->d_exprs.append(expr());
        else
            vg->d_exprs.append(0);
        while( la.d_type == Tok_Colon )
        {
            expect(Tok_Colon, false, "viewgroup");
            if( FIRST_expr(la.d_type) )
                vg->d_exprs.append(expr());
            else
                vg->d_exprs.append(0);
        }
        c->d_viewGroups.append(vg);

        while( la.d_type == Tok_Comma )
        {
            expect(Tok_Comma, false, "viewargs");
            vg = new ViewGroup();
            if( FIRST_expr(la.d_type) )
                vg->d_exprs.append(expr());
            else
                vg->d_exprs.append(0);
            while( la.d_type == Tok_Colon )
            {
                expect(Tok_Colon, false, "viewgroup");
                if( FIRST_expr(la.d_type) )
                    vg->d_exprs.append(expr());
                else
                    vg->d_exprs.append(0);
            }
            c->d_viewGroups.append(vg);
        }
    }
    return c;
}

Command* Parser2::write_()
{
    CMD_PROLOGUE(Tok_WRITE, "write_");
    if( FIRST_writeargs(la.d_type) )
    {
        // writearg: '!' | '#' | '?' expr | '*' expr | expr
        WriteArg* wa = new WriteArg();
        if( la.d_type == Tok_Bang )
        {
            wa->d_kind = WriteArg::NewLine;
            expect(Tok_Bang, false, "writearg");
        } else if( la.d_type == Tok_Hash )
        {
            wa->d_kind = WriteArg::FormFeed;
            expect(Tok_Hash, false, "writearg");
        } else if( la.d_type == Tok_Qmark )
        {
            wa->d_kind = WriteArg::Tab;
            expect(Tok_Qmark, false, "writearg");
            wa->d_expr = expr();
        } else if( la.d_type == Tok_Star )
        {
            wa->d_kind = WriteArg::Star;
            expect(Tok_Star, false, "writearg");
            wa->d_expr = expr();
        }
        else if( FIRST_expr(la.d_type) )
        {
            wa->d_kind = WriteArg::Expr;
            wa->d_expr = expr();
        }else
            invalid("writearg");
        c->d_writeArgs.append(wa);

        while( la.d_type == Tok_Comma || FIRST_writearg(la.d_type) )
        {
            if( la.d_type == Tok_Comma )
                expect(Tok_Comma, false, "writeargs");

            wa = new WriteArg();
            if( la.d_type == Tok_Bang )
            {
                wa->d_kind = WriteArg::NewLine;
                expect(Tok_Bang, false, "writearg");
            }  else if( la.d_type == Tok_Hash )
            {
                wa->d_kind = WriteArg::FormFeed;
                expect(Tok_Hash, false, "writearg");
            } else if( la.d_type == Tok_Qmark )
            {
                wa->d_kind = WriteArg::Tab;
                expect(Tok_Qmark, false, "writearg");
                wa->d_expr = expr();
            } else if( la.d_type == Tok_Star )
            {
                wa->d_kind = WriteArg::Star;
                expect(Tok_Star, false, "writearg");
                wa->d_expr = expr();
            } else if( FIRST_expr(la.d_type) )
            {
                wa->d_kind = WriteArg::Expr;
                wa->d_expr = expr();
            }else
            {
                invalid("writearg");
                delete wa;
                break;
            }
            c->d_writeArgs.append(wa);
        }
    }
    return c;
}

Command* Parser2::xecute_()
{
    CMD_PROLOGUE(Tok_XECUTE, "xecute_");
    // xecuteargs: xecutearg { ',' xecutearg }
    {
        XecuteArg* xa = new XecuteArg();
        xa->d_expr = expr();
        if( FIRST_postcond(la.d_type) )
            xa->d_postcond = postcond();
        c->d_xecuteArgs.append(xa);
    }

    while( la.d_type == Tok_Comma )
    {
        expect(Tok_Comma, false, "xecuteargs");
        XecuteArg* xa = new XecuteArg();
        xa->d_expr = expr();
        if( FIRST_postcond(la.d_type) )
            xa->d_postcond = postcond();
        c->d_xecuteArgs.append(xa);
    }
    return c;
}

Command* Parser2::new_()
{
    CMD_PROLOGUE(Tok_NEW, "new_");
    if( FIRST_newargs(la.d_type) )
    {
        // newarg: ident | '(' ident { ',' ident } ')'
        if( la.d_type == Tok_ident )
        {
            c->d_newVars.append(la.d_val);
            expect(Tok_ident, false, "newarg");
        } else if( la.d_type == Tok_Lpar )
        {
            c->d_newExclusive = true;
            expect(Tok_Lpar, false, "newarg");
            if( la.d_type == Tok_ident )
            {
                c->d_newVars.append(la.d_val);
                expect(Tok_ident, false, "newarg");
            }
            while( la.d_type == Tok_Comma )
            {
                expect(Tok_Comma, false, "newarg");
                if( la.d_type == Tok_ident )
                {
                    c->d_newVars.append(la.d_val);
                    expect(Tok_ident, false, "newarg");
                }
            }
            expect(Tok_Rpar, false, "newarg");
        }else
            invalid("newarg");

        while( la.d_type == Tok_Comma )
        {
            expect(Tok_Comma, false, "newargs");
            if( la.d_type == Tok_ident )
            {
                c->d_newVars.append(la.d_val);
                expect(Tok_ident, false, "newarg");
            }else if( la.d_type == Tok_Lpar )
            {
                c->d_newExclusive = true;
                expect(Tok_Lpar, false, "newarg");
                if( la.d_type == Tok_ident )
                {
                    c->d_newVars.append(la.d_val);
                    expect(Tok_ident, false, "newarg");
                }
                while( la.d_type == Tok_Comma )
                {
                    expect(Tok_Comma, false, "newarg");
                    if( la.d_type == Tok_ident )
                    {
                        c->d_newVars.append(la.d_val);
                        expect(Tok_ident, false, "newarg");
                    }
                }
                expect(Tok_Rpar, false, "newarg");
            }else
                invalid("newarg");
        }
    }
    return c;
}

Command* Parser2::job_()
{
    CMD_PROLOGUE(Tok_JOB, "job_");
    // jobargs: entryref [ ':' expr { ':' expr } ]
    c->d_jobEntry = entryref();
    if( la.d_type == Tok_Colon )
    {
        expect(Tok_Colon, false, "jobargs");
        c->d_jobParams.append(expr());
        while( la.d_type == Tok_Colon )
        {
            expect(Tok_Colon, false, "jobargs");
            c->d_jobParams.append(expr());
        }
    }
    return c;
}

Command* Parser2::zcmd_()
{
    Command* c = new Command();
    c->d_lineNr = la.d_lineNr;
    c->d_colNr = la.d_colNr;
    c->d_type = Tok_ZCMD;
    c->d_zcmdName = la.d_val;
    expect(Tok_ZCMD, false, "zcmd_");
    if( FIRST_postcond(la.d_type) )
        c->d_postcond = postcond();
    if( la.d_type == Tok_CmdSep )
        expect(Tok_CmdSep, false, "zcmd_");

    if( FIRST_zargs(la.d_type) )
    {
        // zargs: '(' openparam... ')' | expr ['^' routineref] [openparams] ...
        if( peek(1).d_type == Tok_Lpar )
        {
            // paren-grouped form: (openparam { : openparam })
            DeviceArg* da = new DeviceArg();
            expect(Tok_Lpar, false, "zargs");
            openparam(da->d_params);
            while( la.d_type == Tok_Colon )
            {
                expect(Tok_Colon, false, "zargs");
                openparam(da->d_params);
            }
            expect(Tok_Rpar, false, "zargs");
            c->d_deviceArgs.append(da);
        }
        else if( FIRST_expr(la.d_type) )
        {
            DeviceArg* da = new DeviceArg();
            da->d_expr = expr();
            if( la.d_type == Tok_Hat )
            {
                expect(Tok_Hat, false, "zargs");
                // routineref: ident | '@' expratom
                if( la.d_type == Tok_ident )
                {
                    // Store routine as a param expression
                    Expression* re = new Expression();
                    re->d_lineNr = la.d_lineNr;
                    re->d_colNr = la.d_colNr;
                    ExprAtom* ra = new ExprAtom();
                    ra->d_tag = ExprAtom::LocalVar;
                    ra->d_name = la.d_val;
                    ra->d_lineNr = la.d_lineNr;
                    ra->d_colNr = la.d_colNr;
                    re->d_operands.append(ra);
                    da->d_params.append(re);
                    expect(Tok_ident, false, "routineref");
                }else if( la.d_type == Tok_At )
                {
                    expect(Tok_At, false, "routineref");
                    Expression* re = new Expression();
                    re->d_lineNr = la.d_lineNr;
                    re->d_colNr = la.d_colNr;
                    re->d_operands.append(expratom());
                    da->d_params.append(re);
                }else
                    invalid("routineref");
            }
            if( FIRST_openparams(la.d_type) )
                openparams(da->d_params);
            c->d_deviceArgs.append(da);

            while( la.d_type == Tok_Comma )
            {
                expect(Tok_Comma, false, "zargs");
                da = new DeviceArg();
                da->d_expr = expr();
                if( la.d_type == Tok_Hat )
                {
                    expect(Tok_Hat, false, "zargs");
                    if( la.d_type == Tok_ident )
                    {
                        Expression* re = new Expression();
                        re->d_lineNr = la.d_lineNr;
                        re->d_colNr = la.d_colNr;
                        ExprAtom* ra = new ExprAtom();
                        ra->d_tag = ExprAtom::LocalVar;
                        ra->d_name = la.d_val;
                        ra->d_lineNr = la.d_lineNr;
                        ra->d_colNr = la.d_colNr;
                        re->d_operands.append(ra);
                        da->d_params.append(re);
                        expect(Tok_ident, false, "routineref");
                    }else if( la.d_type == Tok_At )
                    {
                        expect(Tok_At, false, "routineref");
                        Expression* re = new Expression();
                        re->d_lineNr = la.d_lineNr;
                        re->d_colNr = la.d_colNr;
                        re->d_operands.append(expratom());
                        da->d_params.append(re);
                    } else
                        invalid("routineref");
                }
                if( FIRST_openparams(la.d_type) )
                    openparams(da->d_params);
                c->d_deviceArgs.append(da);
            }
        }else
            invalid("zargs");
    }
    return c;
}

void Parser2::openargs(QList<DeviceArg*>& args)
{
    args.append(openarg());
    while( la.d_type == Tok_Comma )
    {
        expect(Tok_Comma, false, "openargs");
        args.append(openarg());
    }
}

DeviceArg* Parser2::openarg()
{
    DeviceArg* da = new DeviceArg();
    da->d_expr = expr();
    if( FIRST_openparams(la.d_type) )
        openparams(da->d_params);
    return da;
}

void Parser2::openparams(QList<Expression*>& params)
{
    expect(Tok_Colon, false, "openparams");
    openparam(params);
    while( la.d_type == Tok_Colon )
    {
        expect(Tok_Colon, false, "openparams");
        openparam(params);
    }
}

void Parser2::openparam(QList<Expression*>& params)
{
    if( peek(1).d_type == Tok_Lpar || FIRST_expr(la.d_type) )
    {
        if( peek(1).d_type == Tok_Lpar )
        {
            // grouped: '(' openparam { ':' openparam } ')'
            expect(Tok_Lpar, false, "openparam");
            openparam(params);
            while( la.d_type == Tok_Colon )
            {
                expect(Tok_Colon, false, "openparam");
                openparam(params);
            }
            expect(Tok_Rpar, false, "openparam");
        } else if( FIRST_expr(la.d_type) )
            params.append(expr());
        else
            invalid("openparam");
    }
    // else: empty param, nothing to add
}

Expression* Parser2::expr()
{
    Expression* e = new Expression();
    e->d_lineNr = la.d_lineNr;
    e->d_colNr = la.d_colNr;

    e->d_operands.append(expratom());

    while( FIRST_binop(la.d_type) || la.d_type == Tok_Qmark || la.d_type == Tok_tick )
    {
        if( FIRST_binop(la.d_type) )
        {
            quint16 op = la.d_type;
            next();
            e->d_ops.append(BinOp(op, false));
            e->d_operands.append(expratom());
        }else if( la.d_type == Tok_Qmark )
        {
            next();
            e->d_ops.append(BinOp(Tok_Qmark, false));
            ExprAtom* pat = new ExprAtom();
            pat->d_tag = ExprAtom::PatternMatch;
            pat->d_lineNr = la.d_lineNr;
            pat->d_colNr = la.d_colNr;
            pat->d_pattern = pattern();
            e->d_operands.append(pat);
        }else if( la.d_type == Tok_tick )
        {
            next(); // consume tick
            // exprCont: '?' pattern  OR  'binop expratom
            if( la.d_type == Tok_Qmark )
            {
                next();
                e->d_ops.append(BinOp(Tok_Qmark, true));
                ExprAtom* pat = new ExprAtom();
                pat->d_tag = ExprAtom::PatternMatch;
                pat->d_lineNr = la.d_lineNr;
                pat->d_colNr = la.d_colNr;
                pat->d_pattern = pattern();
                e->d_operands.append(pat);
            } else if( FIRST_binop(la.d_type) )
            {
                quint16 op = la.d_type;
                next();
                e->d_ops.append(BinOp(op, true));
                e->d_operands.append(expratom());
            } else
                invalid("exprCont");
        }
    }

    return e;
}

ExprAtom* Parser2::expratom()
{
    ExprAtom* a = new ExprAtom();
    a->d_lineNr = la.d_lineNr;
    a->d_colNr = la.d_colNr;

    if( FIRST_numlit(la.d_type) )
    {
        a->d_tag = ExprAtom::NumLit;
        a->d_val = la.d_val;
        next();
    }else if( la.d_type == Tok_string )
    {
        a->d_tag = ExprAtom::StringLit;
        a->d_val = la.d_val;
        expect(Tok_string, false, "expratom");
    }else if( la.d_type == Tok_ident )
    {
        // ident [ '(' exprlist ')' ]
        a->d_name = la.d_val;
        expect(Tok_ident, false, "expratom");
        if( la.d_type == Tok_Lpar )
        {
            // Subscripted local variable: name(sub1,sub2,...)
            a->d_tag = ExprAtom::LocalVar;
            expect(Tok_Lpar, false, "expratom");
            exprlist(a->d_args);
            expect(Tok_Rpar, false, "expratom");
        } else
            // Bare identifier, local var without subscripts
            a->d_tag = ExprAtom::LocalVar;
    }else if( la.d_type == Tok_Hat )
    {
        // '^' gvntail -> global variable
        expect(Tok_Hat, false, "expratom");
        ExprAtom* gvn = gvntail();
        // Transfer gvntail result into a
        a->d_tag = gvn->d_tag;
        a->d_name = gvn->d_name;
        a->d_val = gvn->d_val;
        a->d_expr = gvn->d_expr;
        gvn->d_expr = 0;
        a->d_args = gvn->d_args;
        gvn->d_args.clear();
        delete gvn;
    } else if( FIRST_dollaritem(la.d_type) )
    {
        ExprAtom* di = dollaritem();
        // Transfer dollaritem result into a
        a->d_tag = di->d_tag;
        a->d_name = di->d_name;
        a->d_val = di->d_val;
        a->d_routine = di->d_routine;
        a->d_args = di->d_args;
        di->d_args.clear();
        delete di;
    }else if( la.d_type == Tok_Lpar )
    {
        // '(' expr ')', grouped expression
        a->d_tag = ExprAtom::GroupedExpr;
        expect(Tok_Lpar, false, "expratom");
        a->d_groupedExpr = expr();
        expect(Tok_Rpar, false, "expratom");
    }else if( FIRST_unaryop(la.d_type) )
    {
        // unaryop expratom
        a->d_tag = ExprAtom::UnaryOp;
        a->d_op = la.d_type;
        a->d_negated = (la.d_type == Tok_tick);
        next();
        a->d_expr = expratom();
    }else if( la.d_type == Tok_At )
    {
        // '@' expratom [ \LL:2\ '@' '(' exprlist ')' ]
        a->d_tag = ExprAtom::Indirection;
        expect(Tok_At, false, "expratom");
        a->d_expr = expratom();
        if( peek(1).d_type == Tok_At && peek(2).d_type == Tok_Lpar )
        {
            expect(Tok_At, false, "expratom");
            expect(Tok_Lpar, false, "expratom");
            exprlist(a->d_args);
            expect(Tok_Rpar, false, "expratom");
        }
    } else
        invalid("expratom");

    return a;
}

ExprAtom* Parser2::numlit()
{
    ExprAtom* a = new ExprAtom();
    a->d_tag = ExprAtom::NumLit;
    a->d_lineNr = la.d_lineNr;
    a->d_colNr = la.d_colNr;
    a->d_val = la.d_val;
    if( la.d_type == Tok_integer )
        expect(Tok_integer, false, "numlit");
    else if( la.d_type == Tok_real )
        expect(Tok_real, false, "numlit");
    else
        invalid("numlit");
    return a;
}

ExprAtom* Parser2::gvntail()
{
    ExprAtom* a = new ExprAtom();
    a->d_lineNr = la.d_lineNr;
    a->d_colNr = la.d_colNr;

    if( la.d_type == Tok_ident )
    {
        // ident [ '(' exprlist ')' ]
        a->d_tag = ExprAtom::GlobalVar;
        a->d_name = la.d_val;
        expect(Tok_ident, false, "gvntail");
        if( la.d_type == Tok_Lpar )
        {
            expect(Tok_Lpar, false, "gvntail");
            exprlist(a->d_args);
            expect(Tok_Rpar, false, "gvntail");
        }
    }else if( la.d_type == Tok_Lpar )
    {
        // '(' exprlist ')', naked global ref
        a->d_tag = ExprAtom::NakedGlobal;
        expect(Tok_Lpar, false, "gvntail");
        exprlist(a->d_args);
        expect(Tok_Rpar, false, "gvntail");
    }else if( la.d_type == Tok_At )
    {
        // '@' expratom [ \LL:2\ '@' '(' exprlist ')' ], indirect global
        a->d_tag = ExprAtom::Indirection;
        expect(Tok_At, false, "gvntail");
        a->d_expr = expratom();
        if( peek(1).d_type == Tok_At && peek(2).d_type == Tok_Lpar )
        {
            expect(Tok_At, false, "gvntail");
            expect(Tok_Lpar, false, "gvntail");
            exprlist(a->d_args);
            expect(Tok_Rpar, false, "gvntail");
        }
    }else
        invalid("gvntail");
    return a;
}

ExprAtom* Parser2::dollaritem()
{
    ExprAtom* a = new ExprAtom();
    a->d_lineNr = la.d_lineNr;
    a->d_colNr = la.d_colNr;

    if( la.d_type == Tok_Dlr )
    {
        // '$' ident [ '(' funcargs ')' ]
        expect(Tok_Dlr, false, "dollaritem");
        if( la.d_type != Tok_ident )
        {
            invalid("dollaritem");
            return a;
        }
        a->d_name = la.d_val;
        expect(Tok_ident, false, "dollaritem");
        if( la.d_type == Tok_Lpar )
        {
            a->d_tag = ExprAtom::IntrinsicFunc;
            expect(Tok_Lpar, false, "dollaritem");
            funcargs(a->d_args);
            expect(Tok_Rpar, false, "dollaritem");
        } else
            a->d_tag = ExprAtom::SpecialVar;
    }else if( la.d_type == Tok_2Dlr )
    {
        // '$$' [ident] [\LL:2\ '^' ident] ['(' funcargs ')']
        a->d_tag = ExprAtom::ExtrinsicFunc;
        expect(Tok_2Dlr, false, "dollaritem");
        if( la.d_type == Tok_ident )
        {
            a->d_name = la.d_val;
            expect(Tok_ident, false, "dollaritem");
        }
        if( peek(1).d_type == Tok_Hat && peek(2).d_type == Tok_ident )
        {
            expect(Tok_Hat, false, "dollaritem");
            a->d_routine = la.d_val;
            expect(Tok_ident, false, "dollaritem");
        }
        if( la.d_type == Tok_Lpar )
        {
            expect(Tok_Lpar, false, "dollaritem");
            funcargs(a->d_args);
            expect(Tok_Rpar, false, "dollaritem");
        }
    } else
        invalid("dollaritem");
    return a;
}

void Parser2::exprlist(QList<Expression*>& list)
{
    // exprlist: ['.'] expr { ',' ['.'] expr }
    if( la.d_type == Tok_Dot )
        expect(Tok_Dot, false, "exprlist");
    list.append(expr());
    while( la.d_type == Tok_Comma )
    {
        expect(Tok_Comma, false, "exprlist");
        if( la.d_type == Tok_Dot )
            expect(Tok_Dot, false, "exprlist");
        list.append(expr());
    }
}

void Parser2::funcargs(QList<Expression*>& args)
{
    // funcargs: [ funcarg { ',' funcarg } ]
    // funcarg: expr [ '^' routineref ] [ ':' expr ]
    if( FIRST_funcarg(la.d_type) )
    {
        args.append(expr());
        // optional '^' routineref  (rare, for $TEXT etc.)
        if( la.d_type == Tok_Hat )
        {
            expect(Tok_Hat, false, "funcarg");
            // routineref: ident | '@' expratom
            if( la.d_type == Tok_ident )
            {
                // Store as another arg
                Expression* re = new Expression();
                re->d_lineNr = la.d_lineNr;
                re->d_colNr = la.d_colNr;
                ExprAtom* ra = new ExprAtom();
                ra->d_tag = ExprAtom::LocalVar;
                ra->d_name = la.d_val;
                ra->d_lineNr = la.d_lineNr;
                ra->d_colNr = la.d_colNr;
                re->d_operands.append(ra);
                args.append(re);
                expect(Tok_ident, false, "routineref");
            }else if( la.d_type == Tok_At )
            {
                expect(Tok_At, false, "routineref");
                Expression* re = new Expression();
                re->d_lineNr = la.d_lineNr;
                re->d_colNr = la.d_colNr;
                re->d_operands.append(expratom());
                args.append(re);
            }else
                invalid("routineref");
        }
        // optional ':' expr (for $SELECT colon-separated args)
        if( la.d_type == Tok_Colon )
        {
            expect(Tok_Colon, false, "funcarg");
            args.append(expr());
        }

        while( la.d_type == Tok_Comma )
        {
            expect(Tok_Comma, false, "funcargs");
            args.append(expr());
            if( la.d_type == Tok_Hat )
            {
                expect(Tok_Hat, false, "funcarg");
                if( la.d_type == Tok_ident )
                {
                    Expression* re = new Expression();
                    re->d_lineNr = la.d_lineNr;
                    re->d_colNr = la.d_colNr;
                    ExprAtom* ra = new ExprAtom();
                    ra->d_tag = ExprAtom::LocalVar;
                    ra->d_name = la.d_val;
                    ra->d_lineNr = la.d_lineNr;
                    ra->d_colNr = la.d_colNr;
                    re->d_operands.append(ra);
                    args.append(re);
                    expect(Tok_ident, false, "routineref");
                }else if( la.d_type == Tok_At )
                {
                    expect(Tok_At, false, "routineref");
                    Expression* re = new Expression();
                    re->d_lineNr = la.d_lineNr;
                    re->d_colNr = la.d_colNr;
                    re->d_operands.append(expratom());
                    args.append(re);
                } else
                    invalid("routineref");
            }
            if( la.d_type == Tok_Colon )
            {
                expect(Tok_Colon, false, "funcarg");
                args.append(expr());
            }
        }
    }
}

Pattern* Parser2::pattern()
{
    // pattern ::= patAtom { patAtom }
    Pattern* p = new Pattern();
    p->d_elems.append(patAtom());
    while( FIRST_pattern(la.d_type) )
        p->d_elems.append(patAtom());
    return p;
}

PatElem* Parser2::patAtom()
{
    // patAtom ::= [ numlit | '.' ] ( ident | string | '(' patAlt ')' | '@' expratom )
    PatElem* pe = new PatElem();

    // Optional repetition count: numlit or '.'
    // In pattern context, a real like "1.3" means min=1, max=3;
    // ".5" means min=0, max=5; "2." means min=2, max=unlimited.
    if( FIRST_numlit(la.d_type) || la.d_type == Tok_Dot )
    {
        if( la.d_type == Tok_real )
        {
            // Real token in pattern context: split at '.'
            QByteArray val = la.d_val;
            int dotPos = val.indexOf('.');
            QByteArray minStr = val.left(dotPos);
            QByteArray maxStr = val.mid(dotPos + 1);
            pe->d_min = minStr.isEmpty() ? 0 : minStr.toInt();
            pe->d_max = maxStr.isEmpty() ? -1 : maxStr.toInt();
            next();
        }else if( la.d_type == Tok_integer )
        {
            int count = la.d_val.toInt();
            next();
            if( la.d_type == Tok_Dot )
            {
                pe->d_min = count;
                next();
                if( FIRST_numlit(la.d_type) )
                {
                    pe->d_max = la.d_val.toInt();
                    next();
                }else
                {
                    pe->d_max = -1; // unlimited
                }
            }else
            {
                pe->d_min = count;
                pe->d_max = count;
            }
        }else if( la.d_type == Tok_Dot )
        {
            pe->d_min = 0;
            pe->d_max = -1; // unlimited
            next();
            if( FIRST_numlit(la.d_type) )
            {
                pe->d_max = la.d_val.toInt();
                next();
            }
        }
    }

    // Required code/literal/alternation/indirection
    if( la.d_type == Tok_ident )
    {
        pe->d_kind = PatElem::Codes;
        QByteArray val = la.d_val;
        // In pattern context, an ident like "A1N" must be split:
        // "A" is the code for this atom, "1N" starts the next atom.
        int splitPos = -1;
        for( int k = 0; k < val.size(); k++ )
        {
            if( val[k] >= '0' && val[k] <= '9' )
            {
                splitPos = k;
                break;
            }
        }
        if( splitPos > 0 )
        {
            pe->d_codes = val.left(splitPos);
            QByteArray remainder = val.mid(splitPos);
            // Split remainder into leading digits and trailing letters
            int j = 0;
            while( j < remainder.size() && remainder[j] >= '0' && remainder[j] <= '9' )
                j++;
            Token numTok;
            numTok.d_type = Tok_integer;
            numTok.d_val = remainder.left(j);
            numTok.d_lineNr = la.d_lineNr;
            numTok.d_colNr = la.d_colNr + splitPos;
            numTok.d_sourcePath = la.d_sourcePath;
            d_queue.append(numTok);
            if( j < remainder.size() )
            {
                Token identTok;
                identTok.d_type = Tok_ident;
                identTok.d_val = remainder.mid(j);
                identTok.d_lineNr = la.d_lineNr;
                identTok.d_colNr = la.d_colNr + splitPos + j;
                identTok.d_sourcePath = la.d_sourcePath;
                d_queue.append(identTok);
            }
        }else
            pe->d_codes = val;

        next(); // consume the ident token
    }else if( la.d_type == Tok_string )
    {
        pe->d_kind = PatElem::Literal;
        // Strip surrounding quotes and unescape doubled quotes
        QByteArray s = la.d_val;
        if( s.size() >= 2 && s[0] == '"' && s[s.size() - 1] == '"' )
        {
            s = s.mid(1, s.size() - 2);
            s.replace("\"\"", "\"");
        }
        pe->d_lit = s;
        expect(Tok_string, false, "patAtom");
    }else if( la.d_type == Tok_Lpar )
    {
        pe->d_kind = PatElem::Alternation;
        expect(Tok_Lpar, false, "patAtom");
        // patAlt: pattern { ',' pattern }
        pe->d_alts.append(pattern());
        while( la.d_type == Tok_Comma )
        {
            expect(Tok_Comma, false, "patAlt");
            pe->d_alts.append(pattern());
        }
        expect(Tok_Rpar, false, "patAtom");
    }else if( la.d_type == Tok_At )
    {
        pe->d_kind = PatElem::IndirectionPat;
        expect(Tok_At, false, "patAtom");
        pe->d_indir = expratom();
    } else
        invalid("patAtom");

    return pe;
}

VarRef* Parser2::glvn()
{
    // glvn ::= ident [ '(' exprlist ')' ]
    //         | '^' gvntail
    //         | '@' expratom [ '(' exprlist ')' ]
    VarRef* v = new VarRef();
    v->d_lineNr = la.d_lineNr;
    v->d_colNr = la.d_colNr;

    if( la.d_type == Tok_ident )
    {
        v->d_kind = VarRef::Local;
        v->d_name = la.d_val;
        expect(Tok_ident, false, "glvn");
        if( la.d_type == Tok_Lpar )
        {
            expect(Tok_Lpar, false, "glvn");
            exprlist(v->d_subs);
            expect(Tok_Rpar, false, "glvn");
        }
    }else if( la.d_type == Tok_Hat )
    {
        expect(Tok_Hat, false, "glvn");
        // gvntail -> fill in VarRef
        if( la.d_type == Tok_ident )
        {
            v->d_kind = VarRef::Global;
            v->d_name = la.d_val;
            expect(Tok_ident, false, "gvntail");
            if( la.d_type == Tok_Lpar )
            {
                expect(Tok_Lpar, false, "gvntail");
                exprlist(v->d_subs);
                expect(Tok_Rpar, false, "gvntail");
            }
        }else if( la.d_type == Tok_Lpar )
        {
            v->d_kind = VarRef::NakedGlobal;
            expect(Tok_Lpar, false, "gvntail");
            exprlist(v->d_subs);
            expect(Tok_Rpar, false, "gvntail");
        }else if( la.d_type == Tok_At )
        {
            v->d_kind = VarRef::Indirect;
            expect(Tok_At, false, "gvntail");
            v->d_indirExpr = expratom();
            if( peek(1).d_type == Tok_At && peek(2).d_type == Tok_Lpar )
            {
                expect(Tok_At, false, "gvntail");
                expect(Tok_Lpar, false, "gvntail");
                exprlist(v->d_subs);
                expect(Tok_Rpar, false, "gvntail");
            }
        }else
            invalid("gvntail");
    }else if( la.d_type == Tok_At )
    {
        v->d_kind = VarRef::Indirect;
        expect(Tok_At, false, "glvn");
        v->d_indirExpr = expratom();
        // The generated parser has complex LL:2 logic here
        if( (peek(1).d_type == Tok_At && peek(2).d_type == Tok_Lpar) || la.d_type == Tok_Lpar )
        {
            if( peek(1).d_type == Tok_At && peek(2).d_type == Tok_Lpar )
            {
                expect(Tok_At, false, "glvn");
                expect(Tok_Lpar, false, "glvn");
                exprlist(v->d_subs);
                expect(Tok_Rpar, false, "glvn");
            }else if( la.d_type == Tok_Lpar )
            {
                expect(Tok_Lpar, false, "glvn");
                exprlist(v->d_subs);
                expect(Tok_Rpar, false, "glvn");
            }
        }
    }else
        invalid("glvn");
    return v;
}

VarRef* Parser2::lvar()
{
    // lvar ::= ident [ '(' exprlist ')' ]
    //        | '@' expratom [ '(' exprlist ')' ]
    VarRef* v = new VarRef();
    v->d_lineNr = la.d_lineNr;
    v->d_colNr = la.d_colNr;

    if( la.d_type == Tok_ident )
    {
        v->d_kind = VarRef::Local;
        v->d_name = la.d_val;
        expect(Tok_ident, false, "lvar");
        if( la.d_type == Tok_Lpar )
        {
            expect(Tok_Lpar, false, "lvar");
            exprlist(v->d_subs);
            expect(Tok_Rpar, false, "lvar");
        }
    }else if( la.d_type == Tok_At )
    {
        v->d_kind = VarRef::Indirect;
        expect(Tok_At, false, "lvar");
        v->d_indirExpr = expratom();
        if( (peek(1).d_type == Tok_At && peek(2).d_type == Tok_Lpar) || la.d_type == Tok_Lpar )
        {
            if( peek(1).d_type == Tok_At && peek(2).d_type == Tok_Lpar )
            {
                expect(Tok_At, false, "lvar");
                expect(Tok_Lpar, false, "lvar");
                exprlist(v->d_subs);
                expect(Tok_Rpar, false, "lvar");
            }else if( la.d_type == Tok_Lpar )
            {
                expect(Tok_Lpar, false, "lvar");
                exprlist(v->d_subs);
                expect(Tok_Rpar, false, "lvar");
            }
        }
    }else
        invalid("lvar");
    return v;
}

VarRef* Parser2::setdest()
{
    // setdest ::= glvn | '$' ident ['(' exprlist ')'] | '(' setdest {',' setdest} ')'
    VarRef* v = new VarRef();
    v->d_lineNr = la.d_lineNr;
    v->d_colNr = la.d_colNr;

    if( FIRST_glvn(la.d_type) )
    {
        // reuse glvn parsing
        delete v;
        v = glvn();
    }else if( la.d_type == Tok_Dlr )
    {
        v->d_kind = VarRef::Dollar;
        expect(Tok_Dlr, false, "setdest");
        if( la.d_type == Tok_ident )
        {
            v->d_name = la.d_val;
            expect(Tok_ident, false, "setdest");
        }else
            invalid("setdest");
        if( la.d_type == Tok_Lpar )
        {
            expect(Tok_Lpar, false, "setdest");
            exprlist(v->d_subs);
            expect(Tok_Rpar, false, "setdest");
        }
    }else if( la.d_type == Tok_Lpar )
    {
        v->d_kind = VarRef::Grouped;
        expect(Tok_Lpar, false, "setdest");
        v->d_group.append(setdest());
        while( la.d_type == Tok_Comma )
        {
            expect(Tok_Comma, false, "setdest");
            v->d_group.append(setdest());
        }
        expect(Tok_Rpar, false, "setdest");
    } else
        invalid("setdest");
    return v;
}

VarRef* Parser2::nref()
{
    // nref ::= glvn | '(' glvn { ',' glvn } ')'
    VarRef* v = new VarRef();
    v->d_lineNr = la.d_lineNr;
    v->d_colNr = la.d_colNr;

    if( FIRST_glvn(la.d_type) )
    {
        delete v;
        v = glvn();
    }else if( la.d_type == Tok_Lpar )
    {
        v->d_kind = VarRef::Grouped;
        expect(Tok_Lpar, false, "nref");
        v->d_group.append(glvn());
        while( la.d_type == Tok_Comma )
        {
            expect(Tok_Comma, false, "nref");
            v->d_group.append(glvn());
        }
        expect(Tok_Rpar, false, "nref");
    }else
        invalid("nref");
    return v;
}

VarRef* Parser2::killarg()
{
    // killarg ::= glvn | '$' ident | '(' glvn { ',' glvn } ')'
    VarRef* v = new VarRef();
    v->d_lineNr = la.d_lineNr;
    v->d_colNr = la.d_colNr;

    if( FIRST_glvn(la.d_type) )
    {
        delete v;
        v = glvn();
    }else if( la.d_type == Tok_Dlr )
    {
        v->d_kind = VarRef::Dollar;
        expect(Tok_Dlr, false, "killarg");
        if( la.d_type == Tok_ident )
        {
            v->d_name = la.d_val;
            expect(Tok_ident, false, "killarg");
        }else
            invalid("killarg");
    }else if( la.d_type == Tok_Lpar )
    {
        v->d_kind = VarRef::Grouped;
        expect(Tok_Lpar, false, "killarg");
        v->d_group.append(glvn());
        while( la.d_type == Tok_Comma )
        {
            expect(Tok_Comma, false, "killarg");
            v->d_group.append(glvn());
        }
        expect(Tok_Rpar, false, "killarg");
    }else
        invalid("killarg");
    return v;
}

EntryRef* Parser2::entryref()
{
    // entryref ::= label_ref ['+' expr] ['^' routineref] ['(' [actuallist] ')']
    //            | '^' routineref ['(' [actuallist] ')']
    //            | '@' expratom ['+' expr] ['^' routineref] ['(' [actuallist] ')']
    EntryRef* e = new EntryRef();
    e->d_lineNr = la.d_lineNr;
    e->d_colNr = la.d_colNr;

    if( FIRST_label_ref(la.d_type) )
    {
        // label_ref: ident | integer
        e->d_label = la.d_val;
        next();

        if( la.d_type == Tok_Plus )
        {
            expect(Tok_Plus, false, "entryref");
            e->d_offset = expr();
        }
        if( la.d_type == Tok_Hat )
        {
            expect(Tok_Hat, false, "entryref");
            // routineref: ident | '@' expratom
            if( la.d_type == Tok_ident )
            {
                e->d_routine = la.d_val;
                expect(Tok_ident, false, "routineref");
            }else if( la.d_type == Tok_At )
            {
                expect(Tok_At, false, "routineref");
                e->d_indirRoutine = expratom();
            }else
                invalid("routineref");
        }
        if( la.d_type == Tok_Lpar )
        {
            expect(Tok_Lpar, false, "entryref");
            if( FIRST_actuallist(la.d_type) )
                actuallist(e->d_actuals, e->d_byRef);
            expect(Tok_Rpar, false, "entryref");
        }
    }else if( la.d_type == Tok_Hat )
    {
        expect(Tok_Hat, false, "entryref");
        // routineref
        if( la.d_type == Tok_ident )
        {
            e->d_routine = la.d_val;
            expect(Tok_ident, false, "routineref");
        }else if( la.d_type == Tok_At )
        {
            expect(Tok_At, false, "routineref");
            e->d_indirRoutine = expratom();
        } else
            invalid("routineref");
        if( la.d_type == Tok_Lpar )
        {
            expect(Tok_Lpar, false, "entryref");
            if( FIRST_actuallist(la.d_type) )
                actuallist(e->d_actuals, e->d_byRef);
            expect(Tok_Rpar, false, "entryref");
        }
    }else if( la.d_type == Tok_At )
    {
        expect(Tok_At, false, "entryref");
        e->d_indirLabel = expratom();
        if( la.d_type == Tok_Plus )
        {
            expect(Tok_Plus, false, "entryref");
            e->d_offset = expr();
        }
        if( la.d_type == Tok_Hat )
        {
            expect(Tok_Hat, false, "entryref");
            if( la.d_type == Tok_ident )
            {
                e->d_routine = la.d_val;
                expect(Tok_ident, false, "routineref");
            }else if( la.d_type == Tok_At )
            {
                expect(Tok_At, false, "routineref");
                e->d_indirRoutine = expratom();
            }else
                invalid("routineref");
        }
        if( la.d_type == Tok_Lpar )
        {
            expect(Tok_Lpar, false, "entryref");
            if( FIRST_actuallist(la.d_type) )
                actuallist(e->d_actuals, e->d_byRef);
            expect(Tok_Rpar, false, "entryref");
        }
    }else
        invalid("entryref");
    return e;
}

void Parser2::actuallist(QList<Expression*>& list, QList<bool>& byRef)
{
    // actuallist ::= ['.'] expr { ',' ['.'] expr }
    bool ref = false;
    if( la.d_type == Tok_Dot )
    {
        ref = true;
        expect(Tok_Dot, false, "actuallist");
    }
    list.append(expr());
    byRef.append(ref);

    while( la.d_type == Tok_Comma )
    {
        expect(Tok_Comma, false, "actuallist");
        ref = false;
        if( la.d_type == Tok_Dot )
        {
            ref = true;
            expect(Tok_Dot, false, "actuallist");
        }
        list.append(expr());
        byRef.append(ref);
    }
}
