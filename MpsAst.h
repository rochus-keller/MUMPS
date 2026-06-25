#ifndef MPSAST_H
#define MPSAST_H

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

/* AST node types for the MUMPS-76 interpreter.

   Expressions use a flat representation:
     Expression = atom { op atom }*   (evaluated strictly left-to-right)

   Commands store their arguments in command-specific fields.
   Lines contain a label, dot-level, and a list of commands.
   A Routine is a list of Lines.
*/

#include <QByteArray>
#include <QList>
#include <QVector>

namespace Mps {

struct Expression;
struct ExprAtom;
struct Pattern;
struct PatElem;


struct BinOp { // A binary operator in an expression chain
    quint16 d_type; // token type (Tok_Plus, Tok_Star, Tok_Lt, etc.)
    bool d_negated; // preceded by ' (tick), e.g. '< means "not less than"

    BinOp() : d_type(0), d_negated(false) {}
    BinOp(quint16 t, bool neg = false) : d_type(t), d_negated(neg) {}
};

struct Expression {
    // flat: operands[0] ops[0] operands[1] ops[1] operands[2] ...
    // d_ops.size() == d_operands.size() - 1 (or both empty for null expression)
    // Evaluated strictly left-to-right (no operator precedence).
    QList<ExprAtom*> d_operands;
    QList<BinOp> d_ops;
    quint32 d_lineNr;
    quint16 d_colNr;

    Expression() : d_lineNr(0), d_colNr(0) {}
    ~Expression();
};

// Single expression atom (operand).
struct ExprAtom {
    enum Tag {
        Invalid,
        NumLit,      // d_val = literal string ("123", "3.14")
        StringLit,   // d_val = string content (without quotes)
        LocalVar,    // d_name, d_args = subscript expressions
        GlobalVar,   // d_name, d_args = subscript expressions (^NAME(...))
        NakedGlobal, // d_args = subscript expressions (^(...) only)
        IntrinsicFunc,   // d_name = function name, d_args = arguments
        SpecialVar,      // d_name = variable name ($X, $T, $H, etc.)
        ExtrinsicFunc,   // d_name = label, d_routine = routine name, d_args = arguments
        Indirection,     // d_expr = target atom, d_args = optional @(subscripts)
        UnaryOp,         // d_op, d_negated, d_expr = operand atom
        GroupedExpr,     // d_groupedExpr = inner expression
        PatternMatch,    // d_pattern = parsed pattern structure
    };

    Tag d_tag;
    QByteArray d_name;
    QByteArray d_val;
    QByteArray d_routine;
    quint16 d_op;  // operator for UnaryOp
    bool d_negated; // for UnaryOp

    ExprAtom* d_expr;  // for UnaryOp operand, Indirection target
    Expression* d_groupedExpr; // for GroupedExpr
    QList<Expression*> d_args; // subscripts or function args
    Pattern* d_pattern;   // for PatternMatch

    quint32 d_lineNr;
    quint16 d_colNr;

    ExprAtom()
        : d_tag(Invalid), d_op(0), d_negated(false),
          d_expr(0), d_groupedExpr(0), d_pattern(0), d_lineNr(0), d_colNr(0) {}
    ~ExprAtom();
};


struct PatElem {
    enum Kind { Codes, Literal, Alternation, IndirectionPat };
    Kind d_kind;
    int d_min;              // minimum repetitions
    int d_max;              // maximum repetitions (-1 for unlimited, via '.')
    QByteArray d_codes;     // for Codes: pattern codes ("N","A","AN","L","U","P","C","E")
    QByteArray d_lit;       // for Literal: literal string to match
    ExprAtom* d_indir;      // for IndirectionPat: @expr
    QList<Pattern*> d_alts; // for Alternation: each alternative is a Pattern

    PatElem() : d_kind(Codes), d_min(0), d_max(0), d_indir(0) {}
    ~PatElem();
};

struct Pattern {
    // Used for the ?pattern and '?pattern match operators.
    // A Pattern is a sequence of PatElems.
    // patAtom ::= [ numlit | '.' ] ( ident | string | '(' patAlt ')' | '@' expratom )
    QList<PatElem*> d_elems;
    ~Pattern();
};

struct VarRef {
    // Unified representation for local/global variable references (SET dest, KILL arg, etc.)
    enum Kind { Local, Global, NakedGlobal, Dollar, Indirect, Grouped };
    Kind d_kind;
    QByteArray d_name;   // variable or $function name
    QList<Expression*> d_subs; // subscript expressions
    ExprAtom* d_indirExpr;  // for Indirect: the @expr
    QList<VarRef*> d_group;  // for Grouped: (var1,var2,...)

    quint32 d_lineNr;
    quint16 d_colNr;

    VarRef()
        : d_kind(Local), d_indirExpr(0), d_lineNr(0), d_colNr(0) {}
    ~VarRef();
};

struct EntryRef {
    // Used by DO, GOTO, JOB commands: label+offset^routine(actuals)
    QByteArray d_label;   // label name or integer
    Expression* d_offset;  // +offset expression (null if none)
    QByteArray d_routine;  // routine name (empty if same routine)
    ExprAtom* d_indirRoutine;  // @expr for indirect routine ref
    ExprAtom* d_indirLabel;    // @expr for indirect entry (entire entryref via @)
    QList<Expression*> d_actuals;   // actual parameters
    QList<bool> d_byRef;   // true if parameter passed by reference (.)

    quint32 d_lineNr;
    quint16 d_colNr;

    EntryRef()
        : d_offset(0), d_indirRoutine(0), d_indirLabel(0),
          d_lineNr(0), d_colNr(0) {}
    ~EntryRef();
};

struct SetArg {
    // SET: destination = expression
    QList<VarRef*> d_dests; // one or more destinations (grouped: (X,Y)=expr)
    Expression* d_expr;    // the value expression (null for bare '=')

    SetArg() : d_expr(0) {}
    ~SetArg();
};

struct ForRange {
    // FOR: start[:increment[:limit]]
    Expression* d_start;
    Expression* d_increment;  // null if not specified
    Expression* d_limit;    // null if not specified

    ForRange() : d_start(0), d_increment(0), d_limit(0) {}
    ~ForRange();
};

struct ReadArg {
    // READ item
    enum Kind { NewLine, FormFeed, Tab, Star, Prompt, Var };
    Kind d_kind;
    Expression* d_expr; // Tab expr, Star var, Var ref, Prompt string
    VarRef* d_var; // for Var and Star
    Expression* d_maxLen; // #expr for READ var#n
    Expression* d_timeout; // :timeout

    ReadArg() : d_kind(NewLine), d_expr(0), d_var(0), d_maxLen(0), d_timeout(0) {}
    ~ReadArg();
};

struct WriteArg {
    // WRITE item
    enum Kind { NewLine, FormFeed, Tab, Star, Expr };
    Kind d_kind;
    Expression* d_expr;  // the expression (Tab, Star, or general Expr)

    WriteArg() : d_kind(NewLine), d_expr(0) {}
    ~WriteArg();
};

struct DeviceArg {
    // OPEN/USE/CLOSE device argument
    Expression* d_expr; // device expression
    QList<Expression*> d_params; // colon-separated params

    DeviceArg() : d_expr(0) {}
    ~DeviceArg();
};

struct LockArg {
    // LOCK name reference
    VarRef* d_ref;
    Expression* d_timeout;

    LockArg() : d_ref(0), d_timeout(0) {}
    ~LockArg();
};

struct ViewGroup {
    // VIEW group: [expr]{:[expr]}
    QList<Expression*> d_exprs; // list of optional expressions (null for empty slots)

    ~ViewGroup();
};

struct XecuteArg {
    // XECUTE argument: expr[:postcond]
    Expression* d_expr;
    Expression* d_postcond;

    XecuteArg() : d_expr(0), d_postcond(0) {}
    ~XecuteArg();
};

struct CondEntry {
    // Postconditioned entry reference (DO, GOTO)
    EntryRef* d_entry;
    Expression* d_postcond;

    CondEntry() : d_entry(0), d_postcond(0) {}
    ~CondEntry();
};

struct Command {
    quint16 d_type;  // Tok_SET, Tok_IF, Tok_GOTO, etc.
    QByteArray d_zcmdName; // original Z-command name (for ZCMD)
    Expression* d_postcond; // command postcondition (:expr after cmd)
    quint32 d_lineNr;
    quint16 d_colNr;

    // TODO: this need to be a union!
    // so far we just collected the things to remember

    // SET
    QList<SetArg*> d_setArgs;

    // IF, BREAK, HALT (expression lists)
    QList<Expression*> d_exprs;

    // FOR
    VarRef* d_forVar;
    QList<ForRange*> d_forRanges;

    // DO, GOTO
    QList<CondEntry*> d_entries;

    // QUIT
    Expression* d_quitExpr;

    // READ
    QList<ReadArg*> d_readArgs;

    // WRITE
    QList<WriteArg*> d_writeArgs;

    // OPEN, CLOSE, USE
    QList<DeviceArg*> d_deviceArgs;

    // KILL
    QList<VarRef*> d_killArgs;

    // LOCK
    QList<LockArg*> d_lockArgs;

    // NEW
    QList<QByteArray> d_newVars;
    bool d_newExclusive; // NEW with exclusive list: NEW (A,B) means NEW all except A,B

    // XECUTE
    QList<XecuteArg*> d_xecuteArgs;

    // JOB
    EntryRef* d_jobEntry;
    QList<Expression*> d_jobParams;

    // VIEW
    QList<ViewGroup*> d_viewGroups;

    // ZCMD (generic: store raw expressions + device args)
    // Reuses d_deviceArgs and d_exprs

    Command()
        : d_type(0), d_postcond(0), d_lineNr(0), d_colNr(0),
          d_forVar(0), d_quitExpr(0), d_newExclusive(false), d_jobEntry(0) {}
    ~Command();
};

struct Line {
    QByteArray d_label;  // label name (empty if none)
    QList<QByteArray> d_params; // label parameters
    int d_dotLevel;  // dot-level (block structure depth)
    QList<Command*> d_commands;
    quint32 d_lineNr;

    Line() : d_dotLevel(0), d_lineNr(0) {}
    ~Line();
};

struct Routine {
    QList<Line*> d_lines;
    QString d_sourcePath;
    QList<QByteArray> d_sourceLines; // original source text lines (1-indexed: [0] unused)

    ~Routine();
};

}

#endif // MPSAST_H
