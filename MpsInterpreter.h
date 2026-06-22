#ifndef MPSINTERPRETER_H
#define MPSINTERPRETER_H

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

#include "MpsAst.h"
#include "MpsValue.h"
#include "MpsNode.h"
#include <QMap>
#include <QStack>
#include <QStringList>
#include <QTextStream>

namespace Mps {

class Interpreter
{
public:
    Interpreter();
    ~Interpreter();

    void addSearchPath(const QString& path);
    void run(const QString& routinePath);
    void run(Routine* routine);

    struct Error
    {
        QString msg;
        quint32 lineNr;
        Error() : lineNr(0) {}
        Error(const QString& m, quint32 ln) : msg(m), lineNr(ln) {}
    };
    QList<Error> errors;

    SymbolTable& locals() { return d_locals; }
    SymbolTable& globals() { return d_globals; }

protected:
    enum Flow { FlowNormal, FlowQuit, FlowGoto, FlowHalt, FlowSkipLine };

    struct StackFrame
    {
        Routine* routine;
        int lineIdx;
        int cmdIdx;
        QMap<QByteArray, Node*> savedVars;
        QList<QByteArray> savedNames;
        bool exclusiveNew;
        QList<QByteArray> exclusiveKeep;
        StackFrame()
            : routine(0), lineIdx(0), cmdIdx(0), exclusiveNew(false) {}
    };

    void runBlock(Routine* routine, int startLine, int dotLevel);
    void executeLineCommands(Line* line, int startCmd);
    void executeCommand(Command* cmd);

    void execSet(Command* cmd);
    void execKill(Command* cmd);
    void execIf(Command* cmd);
    void execElse(Command* cmd);
    void execGoto(Command* cmd);
    void execQuit(Command* cmd);
    void execFor(Command* cmd, Line* line, int cmdIdx);
    void execDo(Command* cmd);
    void execWrite(Command* cmd);
    void execRead(Command* cmd);
    void execNew(Command* cmd);
    void execXecute(Command* cmd);
    void execOpen(Command* cmd);
    void execClose(Command* cmd);
    void execUse(Command* cmd);
    void execLock(Command* cmd);
    void execView(Command* cmd);
    void execHalt(Command* cmd);
    void execBreak(Command* cmd);
    void execJob(Command* cmd);
    void execZcmd(Command* cmd);

    Value evalExpr(Expression* e);
    Value evalAtom(ExprAtom* a);
    Value applyBinOp(const Value& lhs, const BinOp& op, const Value& rhs);

    Value getVar(ExprAtom* a);
    void setVar(VarRef* ref, const Value& val);
    Value getVarRef(VarRef* ref);
    QList<QByteArray> evalSubscripts(const QList<Expression*>& subs);

    Value callIntrinsic(const QByteArray& name, const QList<Expression*>& args, ExprAtom* atom);

    Value getSpecialVar(const QByteArray& name);
    void setSpecialVar(const QByteArray& name, const Value& val);

    bool matchPattern(const QByteArray& str, Pattern* pat);
    bool matchPatElems(const QByteArray& str, int pos, const QList<PatElem*>& elems, int elemIdx);
    bool matchPatElem(const QByteArray& str, int pos, int len, PatElem* pe);
    bool charMatchesCode(char ch, char code);

    int findLabel(Routine* routine, const QByteArray& label);
    Routine* loadRoutine(const QByteArray& name);

    Value callExtrinsic(ExprAtom* a);

    void restoreFrame(const StackFrame& frame);

    void runtimeError(const QString& msg, quint32 lineNr);

private:
    SymbolTable d_locals;
    SymbolTable d_globals;
    QMap<QByteArray, Routine*> d_routineCache;
    QStringList d_searchPaths;

    QStack<StackFrame> d_callStack;
    Routine* d_curRoutine;
    int d_curLine;
    Flow d_flow;
    int d_gotoLine;

    bool d_testFlag;
    int d_xPos;
    int d_yPos;

    QTextStream d_out;
    QTextStream d_in;
};

}

#endif // MPSINTERPRETER_H
