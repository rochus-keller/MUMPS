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
#include "MpsParser2.h"
#include "MpsLexer.h"
#include "MpsCollation.h"
#include <QFile>
#include <QDir>
#include <QFileInfo>
#include <QDateTime>
#include <QCoreApplication>
#include <QtDebug>
#include <qmath.h>
#include <cstdio>
#include <cstdlib>
using namespace Mps;


Interpreter::Interpreter(): d_curRoutine(0), d_curLine(0), d_flow(FlowNormal),
      d_gotoLine(-1), d_testFlag(true), d_xPos(0), d_yPos(0), d_out(stdout), d_in(stdin)
{
}

Interpreter::~Interpreter()
{
    QMap<QByteArray, Routine*>::iterator it;
    for( it = d_routineCache.begin(); it != d_routineCache.end(); ++it )
        delete it.value();
}

void Interpreter::addSearchPath(const QString& path)
{
    d_searchPaths.append(path);
}

void Interpreter::run(const QString& routinePath)
{
    class Lex : public Scanner
    {
    public:
        Lexer lex;
        Token next() { return lex.nextToken(); }
        Token peek(int offset) { return lex.peekToken(offset); }
    };

    Lex lex;
    lex.lex.setStream(routinePath);
    Parser2 parser(&lex);
    Routine* r = parser.parse();
    if( !parser.errors.isEmpty() )
    {
        for( int i = 0; i < parser.errors.size(); i++ )
        {
            const Parser2::Error& e = parser.errors[i];
            errors << Error(e.msg, e.row);
        }
        delete r;
        return;
    }

    QFileInfo fi(routinePath);
    QByteArray name = fi.baseName().toUtf8();
    if( name.startsWith("PCT_") )
        name = "%" + name.mid(4);
    d_routineCache.insert(name, r);
    run(r);
}

void Interpreter::run(Routine* routine)
{
    d_flow = FlowNormal;
    d_curRoutine = routine;
    d_curLine = 0;
    d_callStack.clear();
    runBlock(routine, 0, 0);
}

void Interpreter::runBlock(Routine* routine, int startLine, int dotLevel)
{
    d_curRoutine = routine;
    d_curLine = startLine;

    while( d_curLine < routine->d_lines.size() )
    {
        if( d_flow == FlowHalt )
            return;

        Line* line = routine->d_lines[d_curLine];

        if( line->d_dotLevel < dotLevel )
            return;

        if( line->d_dotLevel > dotLevel )
        {
            d_curLine++;
            continue;
        }

        executeLineCommands(line, 0);

        if( d_flow == FlowSkipLine )
        {
            d_flow = FlowNormal;
            d_curLine++;
            continue;
        }

        if( d_flow == FlowQuit )
        {
            d_flow = FlowNormal;
            return;
        }

        if( d_flow == FlowGoto )
        {
            if( d_gotoLine >= 0 )
            {
                d_curLine = d_gotoLine;
                d_gotoLine = -1;
                d_flow = FlowNormal;
                continue;
            }
            return;
        }

        if( d_flow == FlowHalt )
            return;

        d_curLine++;
    }
}

void Interpreter::executeLineCommands(Line* line, int startCmd)
{
    for( int i = startCmd; i < line->d_commands.size(); i++ )
    {
        if( d_flow != FlowNormal )
            return;

        Command* cmd = line->d_commands[i];

        if( cmd->d_postcond )
        {
            Value cond = evalExpr(cmd->d_postcond);
            if( !cond.toBool() )
                continue;
        }

        if( cmd->d_type == Tok_FOR )
        {
            execFor(cmd, line, i);
            return;
        }

        executeCommand(cmd);
    }
}

void Interpreter::executeCommand(Command* cmd)
{
    switch( cmd->d_type )
    {
    case Tok_SET:
        execSet(cmd);
        break;
    case Tok_KILL:
        execKill(cmd);
        break;
    case Tok_IF:
        execIf(cmd);
        break;
    case Tok_ELSE:
        execElse(cmd);
        break;
    case Tok_GOTO:
        execGoto(cmd);
        break;
    case Tok_QUIT:
        execQuit(cmd);
        break;
    case Tok_DO:
        execDo(cmd);
        break;
    case Tok_WRITE:
        execWrite(cmd);
        break;
    case Tok_READ:
        execRead(cmd);
        break;
    case Tok_NEW:
        execNew(cmd);
        break;
    case Tok_XECUTE:
        execXecute(cmd);
        break;
    case Tok_OPEN:
        execOpen(cmd);
        break;
    case Tok_CLOSE:
        execClose(cmd);
        break;
    case Tok_USE:
        execUse(cmd);
        break;
    case Tok_LOCK:
        execLock(cmd);
        break;
    case Tok_VIEW:
        execView(cmd);
        break;
    case Tok_HALT:
        execHalt(cmd);
        break;
    case Tok_BREAK:
        execBreak(cmd);
        break;
    case Tok_JOB:
        execJob(cmd);
        break;
    case Tok_ZCMD:
        execZcmd(cmd);
        break;
    default:
        runtimeError(QString("unknown command type %1").arg(cmd->d_type), cmd->d_lineNr);
        break;
    }
}

void Interpreter::execSet(Command* cmd)
{
    for( int i = 0; i < cmd->d_setArgs.size(); i++ )
    {
        SetArg* sa = cmd->d_setArgs[i];
        if( sa->d_expr )
        {
            Value val = evalExpr(sa->d_expr);
            for( int j = 0; j < sa->d_dests.size(); j++ )
                setVar(sa->d_dests[j], val);
        }
    }
}

void Interpreter::execKill(Command* cmd)
{
    if( cmd->d_killArgs.isEmpty() )
    {
        d_locals.clear();
        return;
    }

    for( int i = 0; i < cmd->d_killArgs.size(); i++ )
    {
        VarRef* ref = cmd->d_killArgs[i];
        if( ref->d_kind == VarRef::Local )
        {
            if( ref->d_subs.isEmpty() )
                d_locals.remove(ref->d_name);
            else
            {
                Node* node = d_locals.get(ref->d_name);
                if( node )
                {
                    QList<QByteArray> subs = evalSubscripts(ref->d_subs);
                    if( subs.size() == 1 )
                        node->removeChild(subs[0]);
                    else if( subs.size() > 1 )
                    {
                        Node* parent = node;
                        for( int s = 0; s < subs.size() - 1; s++ )
                        {
                            parent = parent->get(subs[s]);
                            if( !parent )
                                break;
                        }
                        if( parent )
                            parent->removeChild(subs.last());
                    }
                }
            }
        }else if( ref->d_kind == VarRef::Global )
        {
            if( ref->d_subs.isEmpty() )
                d_globals.remove(ref->d_name);
            else
            {
                Node* node = d_globals.get(ref->d_name);
                if( node )
                {
                    QList<QByteArray> subs = evalSubscripts(ref->d_subs);
                    if( subs.size() == 1 )
                        node->removeChild(subs[0]);
                    else if( subs.size() > 1 )
                    {
                        Node* parent = node;
                        for( int s = 0; s < subs.size() - 1; s++ )
                        {
                            parent = parent->get(subs[s]);
                            if( !parent )
                                break;
                        }
                        if( parent )
                            parent->removeChild(subs.last());
                    }
                }
            }
        }else if( ref->d_kind == VarRef::Grouped )
        {
            for( int g = 0; g < ref->d_group.size(); g++ )
            {
                VarRef* inner = ref->d_group[g];
                if( inner->d_kind == VarRef::Local )
                    d_locals.remove(inner->d_name);
                else if( inner->d_kind == VarRef::Global )
                    d_globals.remove(inner->d_name);
            }
        }
    }
}

void Interpreter::execIf(Command* cmd)
{
    if( cmd->d_exprs.isEmpty() )
    {
        if( !d_testFlag )
            d_flow = FlowSkipLine;
        return;
    }

    bool result = true;
    for( int i = 0; i < cmd->d_exprs.size(); i++ )
    {
        Value v = evalExpr(cmd->d_exprs[i]);
        if( !v.toBool() )
        {
            result = false;
            break;
        }
    }
    d_testFlag = result;
    if( !result )
        d_flow = FlowSkipLine;
}

void Interpreter::execElse(Command* cmd)
{
    Q_UNUSED(cmd);
    if( d_testFlag )
        d_flow = FlowSkipLine;
}

void Interpreter::execGoto(Command* cmd)
{
    for( int i = 0; i < cmd->d_entries.size(); i++ )
    {
        CondEntry* ce = cmd->d_entries[i];
        if( ce->d_postcond )
        {
            Value cond = evalExpr(ce->d_postcond);
            if( !cond.toBool() )
                continue;
        }

        EntryRef* er = ce->d_entry;
        if( er->d_indirLabel )
        {
            Value label = evalAtom(er->d_indirLabel);
            int idx = findLabel(d_curRoutine, label.str());
            if( idx >= 0 )
            {
                d_gotoLine = idx;
                d_flow = FlowGoto;
            }else
                runtimeError(QString("label '%1' not found").arg( QString::fromUtf8(label.str())), cmd->d_lineNr);
            return;
        }

        Routine* targetRoutine = d_curRoutine;
        if( !er->d_routine.isEmpty() )
        {
            targetRoutine = loadRoutine(er->d_routine);
            if( !targetRoutine )
            {
                runtimeError(QString("routine '%1' not found").arg( QString::fromUtf8(er->d_routine)), cmd->d_lineNr);
                return;
            }
        }

        int idx = -1;
        if( !er->d_label.isEmpty() )
            idx = findLabel(targetRoutine, er->d_label);
        else
            idx = 0;

        if( idx < 0 )
        {
            runtimeError(QString("label '%1' not found").arg(QString::fromUtf8(er->d_label)), cmd->d_lineNr);
            return;
        }

        if( er->d_offset )
        {
            Value off = evalExpr(er->d_offset);
            idx += (int)off.toNumber();
        }

        if( targetRoutine != d_curRoutine )
            d_curRoutine = targetRoutine;
        d_gotoLine = idx;
        d_flow = FlowGoto;
        return;
    }
}

void Interpreter::execQuit(Command* cmd)
{
    if( cmd->d_quitExpr )
    {
        Value retVal = evalExpr(cmd->d_quitExpr);
        Node* retNode = d_locals.getOrCreate("$RETURN$");
        retNode->setValue(retVal.str());
    }
    d_flow = FlowQuit;
}

void Interpreter::execFor(Command* cmd, Line* line, int cmdIdx)
{
    int bodyStart = cmdIdx + 1;

    if( cmd->d_forRanges.isEmpty() )
    {
        // argumentless FOR: infinite loop
        while( d_flow == FlowNormal || d_flow == FlowSkipLine )
        {
            d_flow = FlowNormal;
            executeLineCommands(line, bodyStart);
            if( d_flow == FlowSkipLine )
                continue;
            if( d_flow == FlowQuit )
            {
                d_flow = FlowNormal;
                return;
            }
            if( d_flow == FlowGoto || d_flow == FlowHalt )
                return;
        }
        return;
    }

    for( int r = 0; r < cmd->d_forRanges.size(); r++ )
    {
        ForRange* fr = cmd->d_forRanges[r];
        Value start = evalExpr(fr->d_start);

        if( !fr->d_increment )
        {
            // single value: F var=expr
            if( cmd->d_forVar )
                setVar(cmd->d_forVar, start);
            executeLineCommands(line, bodyStart);
            if( d_flow == FlowSkipLine )
            {
                d_flow = FlowNormal;
                continue;
            }
            if( d_flow == FlowQuit )
            {
                d_flow = FlowNormal;
                return;
            }
            if( d_flow == FlowGoto || d_flow == FlowHalt )
                return;
            continue;
        }

        Value increment = evalExpr(fr->d_increment);
        double inc = increment.toNumber();
        double current = start.toNumber();

        while( true )
        {
            if( fr->d_limit )
            {
                Value limit = evalExpr(fr->d_limit);
                double lim = limit.toNumber();
                if( inc > 0 && current > lim )
                    break;
                if( inc < 0 && current < lim )
                    break;
                if( inc == 0 )
                    break;
            }

            if( cmd->d_forVar )
                setVar(cmd->d_forVar, Value(current));

            executeLineCommands(line, bodyStart);

            if( d_flow == FlowSkipLine )
            {
                d_flow = FlowNormal;
                current += inc;
                continue;
            }
            if( d_flow == FlowQuit )
            {
                d_flow = FlowNormal;
                return;
            }
            if( d_flow == FlowGoto || d_flow == FlowHalt )
                return;

            current += inc;
        }
    }
}

void Interpreter::execDo(Command* cmd)
{
    if( cmd->d_entries.isEmpty() )
    {
        // argumentless DO: enter dot block
        int nextLine = d_curLine + 1;
        int targetDot = -1;

        if( nextLine < d_curRoutine->d_lines.size() )
            targetDot = d_curRoutine->d_lines[nextLine]->d_dotLevel;

        if( targetDot <= 0 )
            return;

        StackFrame frame;
        frame.routine = d_curRoutine;
        frame.lineIdx = d_curLine;
        frame.cmdIdx = 0;
        d_callStack.push(frame);

        runBlock(d_curRoutine, nextLine, targetDot);

        StackFrame restored = d_callStack.pop();
        restoreFrame(restored);
        d_curRoutine = restored.routine;
        d_curLine = restored.lineIdx;
        return;
    }

    for( int i = 0; i < cmd->d_entries.size(); i++ )
    {
        if( d_flow != FlowNormal )
            return;

        CondEntry* ce = cmd->d_entries[i];
        if( ce->d_postcond )
        {
            Value cond = evalExpr(ce->d_postcond);
            if( !cond.toBool() )
                continue;
        }

        EntryRef* er = ce->d_entry;

        if( er->d_indirLabel )
        {
            Value label = evalAtom(er->d_indirLabel);
            int idx = findLabel(d_curRoutine, label.str());
            if( idx < 0 )
            {
                runtimeError(QString("label '%1' not found").arg( QString::fromUtf8(label.str())), cmd->d_lineNr);
                return;
            }

            StackFrame frame;
            frame.routine = d_curRoutine;
            frame.lineIdx = d_curLine;
            frame.cmdIdx = 0;
            d_callStack.push(frame);

            runBlock(d_curRoutine, idx, 0);

            StackFrame restored = d_callStack.pop();
            restoreFrame(restored);
            d_curRoutine = restored.routine;
            d_curLine = restored.lineIdx;
            continue;
        }

        Routine* targetRoutine = d_curRoutine;
        if( !er->d_routine.isEmpty() )
        {
            targetRoutine = loadRoutine(er->d_routine);
            if( !targetRoutine )
            {
                runtimeError(QString("routine '%1' not found").arg( QString::fromUtf8(er->d_routine)), cmd->d_lineNr);
                return;
            }
        }

        int idx = -1;
        if( !er->d_label.isEmpty() )
            idx = findLabel(targetRoutine, er->d_label);
        else
            idx = 0;

        if( idx < 0 )
        {
            runtimeError(QString("label '%1' not found").arg( QString::fromUtf8(er->d_label)), cmd->d_lineNr);
            return;
        }

        if( er->d_offset )
        {
            Value off = evalExpr(er->d_offset);
            idx += (int)off.toNumber();
        }

        // push stack frame
        StackFrame frame;
        frame.routine = d_curRoutine;
        frame.lineIdx = d_curLine;
        frame.cmdIdx = 0;
        d_callStack.push(frame);

        // bind actual parameters to formal parameters
        Line* targetLine = targetRoutine->d_lines[idx];
        for( int p = 0; p < er->d_actuals.size() && p < targetLine->d_params.size(); p++ )
        {
            Value actual = evalExpr(er->d_actuals[p]);
            const QByteArray& formal = targetLine->d_params[p];
            StackFrame& topFrame = d_callStack.top();
            Node* existing = d_locals.detach(formal);
            topFrame.savedNames.append(formal);
            topFrame.savedVars.insert(formal, existing);
            d_locals.getOrCreate(formal)->setValue(actual.str());
        }

        runBlock(targetRoutine, idx, 0);

        StackFrame restored = d_callStack.pop();
        restoreFrame(restored);
        d_curRoutine = restored.routine;
        d_curLine = restored.lineIdx;
    }
}

void Interpreter::execWrite(Command* cmd)
{
    for( int i = 0; i < cmd->d_writeArgs.size(); i++ )
    {
        WriteArg* wa = cmd->d_writeArgs[i];
        switch( wa->d_kind )
        {
        case WriteArg::NewLine:
            d_out << "\n";
            d_out.flush();
            d_xPos = 0;
            d_yPos++;
            break;
        case WriteArg::FormFeed:
            d_out << "\f";
            d_out.flush();
            d_xPos = 0;
            d_yPos = 0;
            break;
        case WriteArg::Tab: {
            int target = 0;
            if( wa->d_expr )
                target = (int)evalExpr(wa->d_expr).toNumber();
            while( d_xPos < target )
            {
                d_out << " ";
                d_xPos++;
            }
            d_out.flush();
            } break;
        case WriteArg::Star: {
            int code = 0;
            if( wa->d_expr )
                code = (int)evalExpr(wa->d_expr).toNumber();
            d_out << QChar(code);
            d_out.flush();
            d_xPos++;
            } break;
        case WriteArg::Expr: {
            Value val = evalExpr(wa->d_expr);
            QString text = QString::fromUtf8(val.str());
            d_out << text;
            d_out.flush();
            d_xPos += text.size();
            } break;
        }
    }
}

void Interpreter::execRead(Command* cmd)
{
    for( int i = 0; i < cmd->d_readArgs.size(); i++ )
    {
        ReadArg* ra = cmd->d_readArgs[i];
        switch( ra->d_kind )
        {
        case ReadArg::NewLine:
            d_out << "\n";
            d_out.flush();
            d_xPos = 0;
            d_yPos++;
            break;
        case ReadArg::FormFeed:
            d_out << "\f";
            d_out.flush();
            d_xPos = 0;
            d_yPos = 0;
            break;
        case ReadArg::Tab: {
            int target = 0;
            if( ra->d_expr )
                target = (int)evalExpr(ra->d_expr).toNumber();
            while( d_xPos < target )
            {
                d_out << " ";
                d_xPos++;
            }
            d_out.flush();
            } break;
        case ReadArg::Prompt: {
            Value val = evalExpr(ra->d_expr);
            QString text = QString::fromUtf8(val.str());
            d_out << text;
            d_out.flush();
            d_xPos += text.size();
            } break;
        case ReadArg::Star: {
            // read single character
            char ch = 0;
            if( std::fread(&ch, 1, 1, stdin) == 1 )
            {
                if( ra->d_var )
                    setVar(ra->d_var, Value((int)((unsigned char)ch)));
            }else
            {
                if( ra->d_var )
                    setVar(ra->d_var, Value(-1));
            }
            }break;
        case ReadArg::Var: {
            // read a line (or limited chars)
            int maxLen = -1;
            if( ra->d_maxLen )
                maxLen = (int)evalExpr(ra->d_maxLen).toNumber();

            QByteArray input;
            if( maxLen > 0 )
            {
                input.resize(maxLen);
                int n = (int)std::fread(input.data(), 1, maxLen, stdin);
                input.resize(n);
            }
            else
            {
                char buf[4096];
                if( std::fgets(buf, sizeof(buf), stdin) )
                {
                    input = QByteArray(buf);
                    if( input.endsWith('\n') )
                        input.chop(1);
                    if( input.endsWith('\r') )
                        input.chop(1);
                }
            }

            if( ra->d_var )
                setVar(ra->d_var, Value(input));
            d_xPos += input.size();
            }break;
        }
    }
}

void Interpreter::execNew(Command* cmd)
{
    if( d_callStack.isEmpty() )
        return;

    StackFrame& frame = d_callStack.top();

    if( cmd->d_newExclusive )
    {
        frame.exclusiveNew = true;
        frame.exclusiveKeep = cmd->d_newVars;
        QList<QByteArray> allVars = d_locals.names();
        for( int i = 0; i < allVars.size(); i++ )
        {
            if( !cmd->d_newVars.contains(allVars[i]) )
            {
                Node* existing = d_locals.detach(allVars[i]);
                frame.savedNames.append(allVars[i]);
                frame.savedVars.insert(allVars[i], existing);
            }
        }
        return;
    }

    for( int i = 0; i < cmd->d_newVars.size(); i++ )
    {
        const QByteArray& name = cmd->d_newVars[i];
        if( frame.savedNames.contains(name) )
            continue;

        Node* existing = d_locals.detach(name);
        frame.savedNames.append(name);
        frame.savedVars.insert(name, existing);
    }
}

void Interpreter::execXecute(Command* cmd)
{
    for( int i = 0; i < cmd->d_xecuteArgs.size(); i++ )
    {
        XecuteArg* xa = cmd->d_xecuteArgs[i];
        if( xa->d_postcond )
        {
            Value cond = evalExpr(xa->d_postcond);
            if( !cond.toBool() )
                continue;
        }

        Value code = evalExpr(xa->d_expr);
        if( code.str().isEmpty() )
            continue;

        class Lex : public Scanner
        {
        public:
            Lexer lex;
            Token next() { return lex.nextToken(); }
            Token peek(int offset) { return lex.peekToken(offset); }
        };

        // prepend space so parser treats it as a labelless line
        QByteArray xcode = " " + code.str();
        Lex lex;
        lex.lex.setStream(xcode, "XECUTE");
        Parser2 parser(&lex);
        Routine* r = parser.parse();

        if( !parser.errors.isEmpty() )
        {
            for( int e = 0; e < parser.errors.size(); e++ )
                runtimeError(QString("XECUTE parse error: %1").arg(parser.errors[e].msg), cmd->d_lineNr);
            delete r;
            continue;
        }

        if( r->d_lines.isEmpty() )
        {
            delete r;
            continue;
        }

        StackFrame frame;
        frame.routine = d_curRoutine;
        frame.lineIdx = d_curLine;
        d_callStack.push(frame);

        Routine* savedRoutine = d_curRoutine;
        int savedLine = d_curLine;

        runBlock(r, 0, 0);

        d_curRoutine = savedRoutine;
        d_curLine = savedLine;

        StackFrame restored = d_callStack.pop();
        restoreFrame(restored);

        delete r;

        if( d_flow == FlowHalt )
            return;
        if( d_flow == FlowQuit )
            d_flow = FlowNormal;
    }
}

void Interpreter::execOpen(Command* cmd)
{
    Q_UNUSED(cmd); // TODO
}

void Interpreter::execClose(Command* cmd)
{
    Q_UNUSED(cmd); // TODO
}

void Interpreter::execUse(Command* cmd)
{
    Q_UNUSED(cmd); // TODO
}

void Interpreter::execLock(Command* cmd)
{
    Q_UNUSED(cmd); // TODO
}

void Interpreter::execView(Command* cmd)
{
    Q_UNUSED(cmd); // TODO
}

void Interpreter::execHalt(Command* cmd)
{
    Q_UNUSED(cmd); // TODO
    d_flow = FlowHalt;
}

void Interpreter::execBreak(Command* cmd)
{
    Q_UNUSED(cmd); // TODO
}

void Interpreter::execJob(Command* cmd)
{
    Q_UNUSED(cmd); // TODO
}

void Interpreter::execZcmd(Command* cmd)
{
    Q_UNUSED(cmd); // TODO
}

Value Interpreter::evalExpr(Expression* e)
{
    if( !e || e->d_operands.isEmpty() )
        return Value();

    Value result = evalAtom(e->d_operands[0]);

    for( int i = 0; i < e->d_ops.size(); i++ )
    {
        if( i + 1 >= e->d_operands.size() )
            break;

        if( e->d_ops[i].d_type == Tok_Qmark )
        {
            ExprAtom* patAtom = e->d_operands[i + 1];
            bool matched = false;
            if( patAtom && patAtom->d_tag == ExprAtom::PatternMatch && patAtom->d_pattern )
                matched = matchPattern(result.str(), patAtom->d_pattern);
            if( e->d_ops[i].d_negated )
                matched = !matched;
            result = Value(QByteArray(matched ? "1" : "0"));
            continue;
        }

        Value rhs = evalAtom(e->d_operands[i + 1]);
        result = applyBinOp(result, e->d_ops[i], rhs);
    }

    return result;
}

Value Interpreter::evalAtom(ExprAtom* a)
{
    if( !a )
        return Value();

    switch( a->d_tag )
    {
    case ExprAtom::NumLit:
        return Value(a->d_val);

    case ExprAtom::StringLit:
    {
        QByteArray s = a->d_val;
        if( s.size() >= 2 && s[0] == '"' && s[s.size() - 1] == '"' )
        {
            s = s.mid(1, s.size() - 2);
            s.replace("\"\"", "\"");
        }
        return Value(s);
    }

    case ExprAtom::LocalVar:
    case ExprAtom::GlobalVar:
    case ExprAtom::NakedGlobal:
        return getVar(a);

    case ExprAtom::IntrinsicFunc:
        return callIntrinsic(a->d_name, a->d_args, a);

    case ExprAtom::SpecialVar:
        return getSpecialVar(a->d_name);

    case ExprAtom::ExtrinsicFunc:
        return callExtrinsic(a);

    case ExprAtom::Indirection:
    {
        Value target = evalAtom(a->d_expr);
        // re-parse target as variable reference, evaluate
        // for @expr, treat it as a variable name
        if( a->d_args.isEmpty() )
        {
            Node* node = d_locals.get(target.str());
            if( node && node->hasValue() )
                return Value(node->value());
            return Value();
        }else
        {
            // @expr@(subs): treat as subscripted
            Node* node = d_locals.get(target.str());
            if( !node )
                return Value();
            QList<QByteArray> subs = evalSubscripts(a->d_args);
            Node* child = node->descend(subs);
            if( child && child->hasValue() )
                return Value(child->value());
            return Value();
        }
    }

    case ExprAtom::UnaryOp:
    {
        Value operand = evalAtom(a->d_expr);
        if( a->d_op == Tok_Plus )
            return operand.positive();
        else if( a->d_op == Tok_Minus )
            return operand.negate();
        else if( a->d_op == Tok_tick )
            return operand.logicalNot();
        return operand;
    }

    case ExprAtom::GroupedExpr:
        return evalExpr(a->d_groupedExpr);

    case ExprAtom::PatternMatch:
        // handled as a binop instead
        Q_ASSERT(false);
        return Value();

    default:
        return Value();
    }
}

Value Interpreter::applyBinOp(const Value& lhs, const BinOp& op, const Value& rhs)
{
    bool result = false;

    switch( op.d_type )
    {
    case Tok_Plus:
        return lhs.add(rhs);
    case Tok_Minus:
        return lhs.subtract(rhs);
    case Tok_Star:
        return lhs.multiply(rhs);
    case Tok_Slash:
        return lhs.divide(rhs);
    case Tok_bslash:
        return lhs.intDivide(rhs);
    case Tok_Hash:
        return lhs.modulo(rhs);
    case Tok_5f: // underscore = concatenation
        return lhs.concatenate(rhs);
    case Tok_Eq:
        result = lhs.equals(rhs);
        if( op.d_negated )
            result = !result;
        return Value(QByteArray(result ? "1" : "0"));
    case Tok_Lt:
        result = lhs.numericLess(rhs);
        if( op.d_negated )
            result = !result;
        return Value(QByteArray(result ? "1" : "0"));
    case Tok_Gt:
        result = lhs.numericGreater(rhs);
        if( op.d_negated )
            result = !result;
        return Value(QByteArray(result ? "1" : "0"));
    case Tok_Lbrack:
        result = lhs.contains(rhs);
        if( op.d_negated )
            result = !result;
        return Value(QByteArray(result ? "1" : "0"));
    case Tok_Rbrack:
        result = lhs.follows(rhs);
        if( op.d_negated )
            result = !result;
        return Value(QByteArray(result ? "1" : "0"));
    case Tok_Amp:
        return lhs.logicalAnd(rhs);
    case Tok_Bang:
        return lhs.logicalOr(rhs);
    case Tok_Qmark:
    {
        // pattern match: rhs has d_tag == PatternMatch
        // the pattern is stored in the ExprAtom, not in Value
        // handled specially
        return Value(QByteArray("0"));
    }
    default:
        return Value();
    }
}

Value Interpreter::getVar(ExprAtom* a)
{
    if( a->d_tag == ExprAtom::LocalVar )
    {
        Node* node = d_locals.get(a->d_name);
        if( !node )
            return Value();

        if( a->d_args.isEmpty() )
        {
            if( node->hasValue() )
                return Value(node->value());
            return Value();
        }

        QList<QByteArray> subs = evalSubscripts(a->d_args);
        Node* child = node->descend(subs);
        if( child && child->hasValue() )
            return Value(child->value());
        return Value();
    } else if( a->d_tag == ExprAtom::GlobalVar )
    {
        Node* node = d_globals.get(a->d_name);
        if( !node )
            return Value();

        if( a->d_args.isEmpty() )
        {
            if( node->hasValue() )
                return Value(node->value());
            return Value();
        }

        QList<QByteArray> subs = evalSubscripts(a->d_args);
        Node* child = node->descend(subs);
        if( child && child->hasValue() )
            return Value(child->value());
        return Value();
    }else if( a->d_tag == ExprAtom::NakedGlobal )
    {
        // TODO
        return Value();
    }

    return Value();
}

void Interpreter::setVar(VarRef* ref, const Value& val)
{
    if( ref->d_kind == VarRef::Local )
    {
        Node* node = d_locals.getOrCreate(ref->d_name);
        if( ref->d_subs.isEmpty() )
            node->setValue(val.str());
        else
        {
            QList<QByteArray> subs = evalSubscripts(ref->d_subs);
            Node* target = node->descendOrCreate(subs);
            target->setValue(val.str());
        }
    }else if( ref->d_kind == VarRef::Global )
    {
        Node* node = d_globals.getOrCreate(ref->d_name);
        if( ref->d_subs.isEmpty() )
            node->setValue(val.str());
        else
        {
            QList<QByteArray> subs = evalSubscripts(ref->d_subs);
            Node* target = node->descendOrCreate(subs);
            target->setValue(val.str());
        }
    }else if( ref->d_kind == VarRef::Dollar )
    {
        QByteArray upper = ref->d_name.toUpper();
        if( (upper == "E" || upper == "EXTRACT") && ref->d_subs.size() >= 2 )
        {
            // SET $EXTRACT(var,from,to) = val
            QList<QByteArray> subs = evalSubscripts(ref->d_subs);
            // subs[0] is the variable expression (evaluated as name)
            if( ref->d_subs.size() >= 2 )
            {
                // First arg is the variable to modify
                ExprAtom* varAtom = 0;
                if( ref->d_subs[0] && !ref->d_subs[0]->d_operands.isEmpty() )
                    varAtom = ref->d_subs[0]->d_operands[0];

                if( varAtom && varAtom->d_tag == ExprAtom::LocalVar )
                {
                    Node* node = d_locals.getOrCreate(varAtom->d_name);
                    QByteArray current = node->hasValue() ? node->value() : QByteArray();
                    int from = 1;
                    int to = from;
                    if( ref->d_subs.size() >= 2 )
                        from = (int)evalExpr(ref->d_subs[1]).toNumber();
                    if( ref->d_subs.size() >= 3 )
                        to = (int)evalExpr(ref->d_subs[2]).toNumber();
                    else
                        to = from;

                    if( from < 1 ) from = 1;
                    while( current.size() < to )
                        current.append(' ');
                    QByteArray result = current.left(from - 1) + val.str()
                                        + current.mid(to);
                    node->setValue(result);
                }
            }
        }else if( (upper == "P" || upper == "PIECE") && ref->d_subs.size() >= 3 )
        {
            // SET $PIECE(var,delim,from[,to]) = val
            ExprAtom* varAtom = 0;
            if( ref->d_subs[0] && !ref->d_subs[0]->d_operands.isEmpty() )
                varAtom = ref->d_subs[0]->d_operands[0];

            if( varAtom && varAtom->d_tag == ExprAtom::LocalVar )
            {
                Node* node = d_locals.getOrCreate(varAtom->d_name);
                QByteArray current = node->hasValue() ? node->value() : QByteArray();
                QByteArray delim = evalExpr(ref->d_subs[1]).str();
                int from = (int)evalExpr(ref->d_subs[2]).toNumber();
                int to = from;
                if( ref->d_subs.size() >= 4 )
                    to = (int)evalExpr(ref->d_subs[3]).toNumber();

                if( !delim.isEmpty() && from >= 1 )
                {
                    QList<QByteArray> pieces;
                    int pos = 0;
                    while( true )
                    {
                        int next = current.indexOf(delim, pos);
                        if( next < 0 )
                        {
                            pieces.append(current.mid(pos));
                            break;
                        }
                        pieces.append(current.mid(pos, next - pos));
                        pos = next + delim.size();
                    }

                    while( pieces.size() < to )
                        pieces.append(QByteArray());

                    for( int p = from; p <= to; p++ )
                    {
                        if( p == from )
                            pieces[p - 1] = val.str();
                        else
                            pieces[p - 1] = QByteArray();
                    }

                    QByteArray result;
                    for( int p = 0; p < pieces.size(); p++ )
                    {
                        if( p > 0 )
                            result.append(delim);
                        result.append(pieces[p]);
                    }
                    node->setValue(result);
                }
            }
        }else
            setSpecialVar(ref->d_name, val);
    } else if( ref->d_kind == VarRef::Grouped )
    {
        for( int i = 0; i < ref->d_group.size(); i++ )
            setVar(ref->d_group[i], val);
    } else if( ref->d_kind == VarRef::Indirect )
    {
        if( ref->d_indirExpr )
        {
            Value name = evalAtom(ref->d_indirExpr);
            Node* node = d_locals.getOrCreate(name.str());
            if( ref->d_subs.isEmpty() )
                node->setValue(val.str());
            else
            {
                QList<QByteArray> subs = evalSubscripts(ref->d_subs);
                node->descendOrCreate(subs)->setValue(val.str());
            }
        }
    }
}

Value Interpreter::getVarRef(VarRef* ref)
{
    if( ref->d_kind == VarRef::Local )
    {
        Node* node = d_locals.get(ref->d_name);
        if( !node )
            return Value();
        if( ref->d_subs.isEmpty() )
        {
            if( node->hasValue() )
                return Value(node->value());
            return Value();
        }
        QList<QByteArray> subs = evalSubscripts(ref->d_subs);
        Node* child = node->descend(subs);
        if( child && child->hasValue() )
            return Value(child->value());
        return Value();
    }else if( ref->d_kind == VarRef::Global )
    {
        Node* node = d_globals.get(ref->d_name);
        if( !node )
            return Value();
        if( ref->d_subs.isEmpty() )
        {
            if( node->hasValue() )
                return Value(node->value());
            return Value();
        }
        QList<QByteArray> subs = evalSubscripts(ref->d_subs);
        Node* child = node->descend(subs);
        if( child && child->hasValue() )
            return Value(child->value());
        return Value();
    }
    return Value();
}

QList<QByteArray> Interpreter::evalSubscripts(const QList<Expression*>& subs)
{
    QList<QByteArray> result;
    for( int i = 0; i < subs.size(); i++ )
        result.append(evalExpr(subs[i]).str());
    return result;
}

Value Interpreter::callIntrinsic(const QByteArray& name, const QList<Expression*>& args, ExprAtom* atom)
{
    Q_UNUSED(atom);
    QByteArray upper = name.toUpper();

    if( upper == "L" || upper == "LENGTH" )
    {
        if( args.isEmpty() )
            return Value(0);
        Value str = evalExpr(args[0]);
        if( args.size() >= 2 )
        {
            Value delim = evalExpr(args[1]);
            if( delim.str().isEmpty() )
                return Value(0);
            int count = 1;
            int pos = 0;
            while( (pos = str.str().indexOf(delim.str(), pos)) >= 0 )
            {
                count++;
                pos += delim.str().size();
            }
            return Value(count);
        }
        return Value(str.str().size());
    }

    if( upper == "E" || upper == "EXTRACT" )
    {
        if( args.isEmpty() )
            return Value();
        Value str = evalExpr(args[0]);
        int from = 1;
        int to = -1;
        if( args.size() >= 2 )
            from = (int)evalExpr(args[1]).toNumber();
        if( args.size() >= 3 )
            to = (int)evalExpr(args[2]).toNumber();
        else
            to = from;

        if( from < 1 )
            from = 1;
        if( to > str.str().size() )
            to = str.str().size();
        if( from > to )
            return Value();

        return Value(str.str().mid(from - 1, to - from + 1));
    }

    if( upper == "P" || upper == "PIECE" )
    {
        if( args.size() < 2 )
            return Value();
        Value str = evalExpr(args[0]);
        Value delim = evalExpr(args[1]);
        int from = 1;
        int to = -1;
        if( args.size() >= 3 )
            from = (int)evalExpr(args[2]).toNumber();
        if( args.size() >= 4 )
            to = (int)evalExpr(args[3]).toNumber();
        else
            to = from;

        if( delim.str().isEmpty() )
            return Value();

        QList<QByteArray> pieces;
        int pos = 0;
        int delimLen = delim.str().size();
        while( true )
        {
            int next = str.str().indexOf(delim.str(), pos);
            if( next < 0 )
            {
                pieces.append(str.str().mid(pos));
                break;
            }
            pieces.append(str.str().mid(pos, next - pos));
            pos = next + delimLen;
        }

        if( from < 1 )
            from = 1;
        if( to < from )
            to = from;

        QByteArray result;
        for( int i = from; i <= to; i++ )
        {
            if( i > from )
                result.append(delim.str());
            if( i - 1 < pieces.size() )
                result.append(pieces[i - 1]);
        }
        return Value(result);
    }

    if( upper == "A" || upper == "ASCII" )
    {
        if( args.isEmpty() )
            return Value(-1);
        Value str = evalExpr(args[0]);
        int pos = 1;
        if( args.size() >= 2 )
            pos = (int)evalExpr(args[1]).toNumber();
        if( pos < 1 || pos > str.str().size() )
            return Value(-1);
        return Value((int)((unsigned char)str.str()[pos - 1]));
    }

    if( upper == "C" || upper == "CHAR" )
    {
        QByteArray result;
        for( int i = 0; i < args.size(); i++ )
        {
            int code = (int)evalExpr(args[i]).toNumber();
            if( code >= 0 && code <= 255 )
                result.append((char)code);
        }
        return Value(result);
    }

    if( upper == "D" || upper == "DATA" )
    {
        if( args.isEmpty() )
            return Value(0);
        // Parse the expression, check what it refers to
        Value v = evalExpr(args[0]);
        // For $DATA we need the variable reference, not its value
        // But the arg is an Expression; we need its first atom
        if( args[0] && !args[0]->d_operands.isEmpty() )
        {
            ExprAtom* a = args[0]->d_operands[0];
            if( a->d_tag == ExprAtom::LocalVar )
            {
                Node* node = d_locals.get(a->d_name);
                if( !node )
                    return Value(0);
                if( a->d_args.isEmpty() )
                    return Value(node->data());
                QList<QByteArray> subs = evalSubscripts(a->d_args);
                Node* child = node->descend(subs);
                if( !child )
                    return Value(0);
                return Value(child->data());
            }else if( a->d_tag == ExprAtom::GlobalVar )
            {
                Node* node = d_globals.get(a->d_name);
                if( !node )
                    return Value(0);
                if( a->d_args.isEmpty() )
                    return Value(node->data());
                QList<QByteArray> subs = evalSubscripts(a->d_args);
                Node* child = node->descend(subs);
                if( !child )
                    return Value(0);
                return Value(child->data());
            }
        }
        return Value(0);
    }

    if( upper == "O" || upper == "ORDER" )
    {
        if( args.isEmpty() )
            return Value();
        int dir = 1;
        if( args.size() >= 2 )
            dir = (int)evalExpr(args[1]).toNumber();

        if( args[0] && !args[0]->d_operands.isEmpty() )
        {
            ExprAtom* a = args[0]->d_operands[0];
            if( a->d_tag == ExprAtom::LocalVar )
            {
                Node* node = d_locals.get(a->d_name);
                if( !node )
                    return Value();
                if( a->d_args.isEmpty() )
                    return Value(node->order(QByteArray(), dir));

                QList<QByteArray> subs = evalSubscripts(a->d_args);
                if( subs.isEmpty() )
                    return Value();
                QByteArray lastSub = subs.last();
                subs.removeLast();
                Node* parent = subs.isEmpty() ? node : node->descend(subs);
                if( !parent )
                    return Value();
                return Value(parent->order(lastSub, dir));
            }else if( a->d_tag == ExprAtom::GlobalVar )
            {
                Node* node = d_globals.get(a->d_name);
                if( !node )
                    return Value();
                if( a->d_args.isEmpty() )
                    return Value(node->order(QByteArray(), dir));

                QList<QByteArray> subs = evalSubscripts(a->d_args);
                if( subs.isEmpty() )
                    return Value();
                QByteArray lastSub = subs.last();
                subs.removeLast();
                Node* parent = subs.isEmpty() ? node : node->descend(subs);
                if( !parent )
                    return Value();
                return Value(parent->order(lastSub, dir));
            }
        }
        return Value();
    }

    if( upper == "S" || upper == "SELECT" )
    {
        // funcargs stores pairs of: condition, value, condition, value, ...
        for( int i = 0; i + 1 < args.size(); i += 2 )
        {
            Value cond = evalExpr(args[i]);
            if( cond.toBool() )
                return evalExpr(args[i + 1]);
        }
        runtimeError("$SELECT: no true condition", 0);
        return Value();
    }

    if( upper == "F" || upper == "FIND" )
    {
        if( args.size() < 2 )
            return Value(0);
        Value str = evalExpr(args[0]);
        Value target = evalExpr(args[1]);
        int start = 0;
        if( args.size() >= 3 )
            start = (int)evalExpr(args[2]).toNumber() - 1;
        if( start < 0 ) start = 0;

        int pos = str.str().indexOf(target.str(), start);
        if( pos < 0 )
            return Value(0);
        return Value(pos + target.str().size() + 1);
    }

    if( upper == "J" || upper == "JUSTIFY" )
    {
        if( args.isEmpty() )
            return Value();
        Value val = evalExpr(args[0]);
        int width = 0;
        if( args.size() >= 2 )
            width = (int)evalExpr(args[1]).toNumber();

        if( args.size() >= 3 )
        {
            int dec = (int)evalExpr(args[2]).toNumber();
            double num = val.toNumber();
            QByteArray formatted = QByteArray::number(num, 'f', dec);
            while( formatted.size() < width )
                formatted.prepend(' ');
            return Value(formatted);
        }

        QByteArray result = val.str();
        while( result.size() < width )
            result.prepend(' ');
        return Value(result);
    }

    if( upper == "T" || upper == "TEXT" )
    {
        if( args.isEmpty() )
            return Value();
        // TODO
        return Value();
    }

    if( upper == "G" || upper == "GET" )
    {
        if( args.isEmpty() )
            return Value();

        Value defaultVal;
        if( args.size() >= 2 )
            defaultVal = evalExpr(args[1]);

        if( args[0] && !args[0]->d_operands.isEmpty() )
        {
            ExprAtom* a = args[0]->d_operands[0];
            if( a->d_tag == ExprAtom::LocalVar )
            {
                Node* node = d_locals.get(a->d_name);
                if( !node )
                    return defaultVal;
                if( a->d_args.isEmpty() )
                {
                    if( node->hasValue() )
                        return Value(node->value());
                    return defaultVal;
                }
                QList<QByteArray> subs = evalSubscripts(a->d_args);
                Node* child = node->descend(subs);
                if( child && child->hasValue() )
                    return Value(child->value());
                return defaultVal;
            }else if( a->d_tag == ExprAtom::GlobalVar )
            {
                Node* node = d_globals.get(a->d_name);
                if( !node )
                    return defaultVal;
                if( a->d_args.isEmpty() )
                {
                    if( node->hasValue() )
                        return Value(node->value());
                    return defaultVal;
                }
                QList<QByteArray> subs = evalSubscripts(a->d_args);
                Node* child = node->descend(subs);
                if( child && child->hasValue() )
                    return Value(child->value());
                return defaultVal;
            }
        }
        return defaultVal;
    }

    if( upper == "TR" || upper == "TRANSLATE" )
    {
        if( args.size() < 2 )
            return Value();
        Value str = evalExpr(args[0]);
        Value from = evalExpr(args[1]);
        QByteArray to;
        if( args.size() >= 3 )
            to = evalExpr(args[2]).str();

        QByteArray result;
        for( int i = 0; i < str.str().size(); i++ )
        {
            int idx = from.str().indexOf(str.str()[i]);
            if( idx < 0 )
                result.append(str.str()[i]);
            else if( idx < to.size() )
                result.append(to[idx]);
            // else: character removed (no replacement in 'to')
        }
        return Value(result);
    }

    if( upper == "R" || upper == "RANDOM" )
    {
        if( args.isEmpty() )
            return Value(0);
        int limit = (int)evalExpr(args[0]).toNumber();
        if( limit <= 0 )
            return Value(0);
        return Value(std::rand() % limit);
    }

    if( upper == "H" || upper == "HOROLOG" )
        return getSpecialVar("H");

    if( upper == "FN" || upper == "FNUMBER" )
    {
        if( args.size() < 2 )
            return Value();
        Value num = evalExpr(args[0]);
        Value code = evalExpr(args[1]);
        // TODO: simplified
        return num;
    }

    if( upper == "Q" || upper == "QUERY" )
    {
        return Value(); // TODO
    }

    if( upper == "NA" || upper == "NAME" )
    {
        return Value(); // TODO
    }

    if( upper == "QL" || upper == "QLENGTH" )
        return Value(0); // TODO
    if( upper == "QS" || upper == "QSUBSCRIPT" )
        return Value(); // TODO

    if( upper == "V" || upper == "VIEW" )
        return Value(0); // TODO

    // Z-functions TODO
    if( upper.startsWith("Z") )
        return Value();

    runtimeError(QString("unknown function $%1").arg(QString::fromUtf8(name)), 0);
    return Value();
}

Value Interpreter::getSpecialVar(const QByteArray& name)
{
    QByteArray upper = name.toUpper();

    if( upper == "T" || upper == "TEST" )
        return Value(QByteArray(d_testFlag ? "1" : "0"));

    if( upper == "H" || upper == "HOROLOG" )
    {
        // days since Dec 31, 1840 + comma + seconds since midnight
        QDate epoch(1840, 12, 31);
        QDate today = QDate::currentDate();
        int days = epoch.daysTo(today);
        QTime now = QTime::currentTime();
        int secs = QTime(0, 0).secsTo(now);
        return Value(QByteArray::number(days) + "," + QByteArray::number(secs));
    }

    if( upper == "IO" || upper == "I" )
        return Value("0");

    if( upper == "J" || upper == "JOB" )
        return Value(QByteArray::number((int)QCoreApplication::applicationPid()));

    if( upper == "S" || upper == "STORAGE" )
        return Value(999999);

    if( upper == "X" )
        return Value(d_xPos);

    if( upper == "Y" )
        return Value(d_yPos);

    if( upper == "ZT" || upper == "ZTRAP" )
        return Value();

    if( upper == "ZE" || upper == "ZERROR" )
        return Value();

    if( upper == "ZV" || upper == "ZVERSION" )
        return Value("MUMPS76-Interp"); // TODO

    return Value();
}

void Interpreter::setSpecialVar(const QByteArray& name, const Value& val)
{
    QByteArray upper = name.toUpper();

    if( upper == "X" )
        d_xPos = (int)val.toNumber();
    else if( upper == "Y" )
        d_yPos = (int)val.toNumber();
    else if( upper == "T" || upper == "TEST" )
        d_testFlag = val.toBool();

    // $EXTRACT(var,from,to)=val for SET $E
    if( upper == "E" || upper == "EXTRACT" )
    {
        // TODO: SET $EXTRACT handled via setdest
    }
    if( upper == "P" || upper == "PIECE" )
    {
        // TODO: SET $PIECE handled via setdest
    }
}

bool Interpreter::matchPattern(const QByteArray& str, Pattern* pat)
{
    if( !pat )
        return false;
    return matchPatElems(str, 0, pat->d_elems, 0);
}

bool Interpreter::matchPatElems(const QByteArray& str, int pos,
                                const QList<PatElem*>& elems, int elemIdx)
{
    if( elemIdx >= elems.size() )
        return pos == str.size();

    PatElem* pe = elems[elemIdx];

    int minRep = pe->d_min;
    int maxRep = pe->d_max;
    if( maxRep < 0 )
        maxRep = str.size() - pos;

    for( int rep = minRep; rep <= maxRep; rep++ )
    {
        if( matchPatElem(str, pos, rep, pe) )
        {
            int newPos = pos;
            if( pe->d_kind == PatElem::Literal )
                newPos = pos + rep * pe->d_lit.size();
            else
                newPos = pos + rep;

            if( matchPatElems(str, newPos, elems, elemIdx + 1) )
                return true;
        }
    }
    return false;
}

bool Interpreter::matchPatElem(const QByteArray& str, int pos, int len, PatElem* pe)
{
    if( pe->d_kind == PatElem::Codes )
    {
        for( int i = 0; i < len; i++ )
        {
            if( pos + i >= str.size() )
                return false;
            bool matches = false;
            for( int c = 0; c < pe->d_codes.size(); c++ )
            {
                if( charMatchesCode(str[pos + i], pe->d_codes[c]) )
                {
                    matches = true;
                    break;
                }
            }
            if( !matches )
                return false;
        }
        return true;
    }else if( pe->d_kind == PatElem::Literal )
    {
        if( len == 0 )
            return true;
        for( int i = 0; i < len; i++ )
        {
            if( pos + i * pe->d_lit.size() + pe->d_lit.size() > str.size() )
                return false;
            if( str.mid(pos + i * pe->d_lit.size(), pe->d_lit.size()) != pe->d_lit )
                return false;
        }
        return true;
    }else if( pe->d_kind == PatElem::Alternation )
    {
        if( len == 0 )
            return true;
        for( int a = 0; a < pe->d_alts.size(); a++ )
        {
            if( matchPatElems(str, pos, pe->d_alts[a]->d_elems, 0) )
                return true;
        }
        return false;
    }
    return false;
}

bool Interpreter::charMatchesCode(char ch, char code)
{
    switch( code )
    {
    case 'N': case 'n':
        return ch >= '0' && ch <= '9';
    case 'A': case 'a':
        return (ch >= 'A' && ch <= 'Z') || (ch >= 'a' && ch <= 'z');
    case 'U': case 'u':
        return ch >= 'A' && ch <= 'Z';
    case 'L': case 'l':
        return ch >= 'a' && ch <= 'z';
    case 'P': case 'p':
        return (ch >= ' ' && ch <= '/') || (ch >= ':' && ch <= '@')
               || (ch >= '[' && ch <= '`') || (ch >= '{' && ch <= '~');
    case 'C': case 'c':
        return (unsigned char)ch < 32 || ch == 127;
    case 'E': case 'e':
        return true;
    default:
        return false;
    }
}

int Interpreter::findLabel(Routine* routine, const QByteArray& label)
{
    if( !routine )
        return -1;
    for( int i = 0; i < routine->d_lines.size(); i++ )
    {
        if( routine->d_lines[i]->d_label == label )
            return i;
    }
    return -1;
}

Routine* Interpreter::loadRoutine(const QByteArray& name)
{
    QByteArray lookupName = name;
    if( d_routineCache.contains(lookupName) )
        return d_routineCache[lookupName];

    // search for file in search paths
    QStringList suffixes;
    suffixes << ".mps" << ".MPS" << ".m" << ".M" << ".rou";

    QString fileName = QString::fromUtf8(name);
    if( fileName.startsWith('%') )
        fileName = "PCT_" + fileName.mid(1);

    for( int p = 0; p < d_searchPaths.size(); p++ )
    {
        for( int s = 0; s < suffixes.size(); s++ )
        {
            QString path = d_searchPaths[p] + "/" + fileName + suffixes[s];
            if( QFile::exists(path) )
            {
                class Lex : public Scanner
                {
                public:
                    Lexer lex;
                    Token next() { return lex.nextToken(); }
                    Token peek(int offset) { return lex.peekToken(offset); }
                };

                Lex lex;
                lex.lex.setStream(path);
                Parser2 parser(&lex);
                Routine* r = parser.parse();
                if( parser.errors.isEmpty() )
                {
                    d_routineCache.insert(lookupName, r);
                    return r;
                }else
                    delete r;
            }
        }
    }

    return 0;
}

Value Interpreter::callExtrinsic(ExprAtom* a)
{
    Routine* targetRoutine = d_curRoutine;
    if( !a->d_routine.isEmpty() )
    {
        targetRoutine = loadRoutine(a->d_routine);
        if( !targetRoutine )
        {
            runtimeError(QString("routine '%1' not found").arg(
                             QString::fromUtf8(a->d_routine)), a->d_lineNr);
            return Value();
        }
    }

    int idx = -1;
    if( !a->d_name.isEmpty() )
        idx = findLabel(targetRoutine, a->d_name);
    else
        idx = 0;

    if( idx < 0 )
    {
        runtimeError(QString("label '%1' not found for $$").arg(
                         QString::fromUtf8(a->d_name)), a->d_lineNr);
        return Value();
    }

    StackFrame frame;
    frame.routine = d_curRoutine;
    frame.lineIdx = d_curLine;
    d_callStack.push(frame);

    // Bind actual parameters
    Line* targetLine = targetRoutine->d_lines[idx];
    for( int p = 0; p < a->d_args.size() && p < targetLine->d_params.size(); p++ )
    {
        Value actual = evalExpr(a->d_args[p]);
        const QByteArray& formal = targetLine->d_params[p];
        StackFrame& topFrame = d_callStack.top();
        Node* existing = d_locals.detach(formal);
        topFrame.savedNames.append(formal);
        topFrame.savedVars.insert(formal, existing);
        d_locals.getOrCreate(formal)->setValue(actual.str());
    }

    // Create a special return value variable
    QByteArray retVarName = "$RETURN$";
    d_locals.getOrCreate(retVarName)->setValue("");

    Routine* savedRoutine = d_curRoutine;
    int savedLine = d_curLine;

    runBlock(targetRoutine, idx, 0);

    // Get return value from QUIT expr
    Node* retNode = d_locals.get(retVarName);
    Value retVal;
    if( retNode && retNode->hasValue() )
        retVal = Value(retNode->value());
    d_locals.remove(retVarName);

    d_curRoutine = savedRoutine;
    d_curLine = savedLine;

    StackFrame restored = d_callStack.pop();
    restoreFrame(restored);

    if( d_flow == FlowQuit )
        d_flow = FlowNormal;

    return retVal;
}

void Interpreter::restoreFrame(const StackFrame& frame)
{
    for( int i = 0; i < frame.savedNames.size(); i++ )
    {
        const QByteArray& name = frame.savedNames[i];
        // remove current version of the variable
        d_locals.remove(name);
        // reattach saved version if it existed
        if( frame.savedVars.contains(name) )
        {
            Node* saved = frame.savedVars[name];
            if( saved )
                d_locals.reattach(name, saved);
        }
    }
}

void Interpreter::runtimeError(const QString& msg, quint32 lineNr)
{
    errors << Error(msg, lineNr);
}
