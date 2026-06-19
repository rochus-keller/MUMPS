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

using namespace Mps;

Expression::~Expression()
{
    qDeleteAll(d_operands);
}

ExprAtom::~ExprAtom()
{
    delete d_expr;
    delete d_groupedExpr;
    qDeleteAll(d_args);
    delete d_pattern;
}

PatElem::~PatElem()
{
    delete d_indir;
    qDeleteAll(d_alts);
}

Pattern::~Pattern()
{
    qDeleteAll(d_elems);
}

VarRef::~VarRef()
{
    delete d_indirExpr;
    qDeleteAll(d_subs);
    qDeleteAll(d_group);
}

EntryRef::~EntryRef()
{
    delete d_offset;
    delete d_indirRoutine;
    delete d_indirLabel;
    qDeleteAll(d_actuals);
}

SetArg::~SetArg()
{
    qDeleteAll(d_dests);
    delete d_expr;
}

ForRange::~ForRange()
{
    delete d_start;
    delete d_increment;
    delete d_limit;
}

ReadArg::~ReadArg()
{
    delete d_expr;
    delete d_var;
    delete d_maxLen;
    delete d_timeout;
}

WriteArg::~WriteArg()
{
    delete d_expr;
}

DeviceArg::~DeviceArg()
{
    delete d_expr;
    qDeleteAll(d_params);
}

LockArg::~LockArg()
{
    delete d_ref;
    delete d_timeout;
}

ViewGroup::~ViewGroup()
{
    qDeleteAll(d_exprs);
}

XecuteArg::~XecuteArg()
{
    delete d_expr;
    delete d_postcond;
}

CondEntry::~CondEntry()
{
    delete d_entry;
    delete d_postcond;
}

Command::~Command()
{
    delete d_postcond;
    qDeleteAll(d_setArgs);
    qDeleteAll(d_exprs);
    delete d_forVar;
    qDeleteAll(d_forRanges);
    qDeleteAll(d_entries);
    delete d_quitExpr;
    qDeleteAll(d_readArgs);
    qDeleteAll(d_writeArgs);
    qDeleteAll(d_deviceArgs);
    qDeleteAll(d_killArgs);
    qDeleteAll(d_lockArgs);
    qDeleteAll(d_xecuteArgs);
    delete d_jobEntry;
    qDeleteAll(d_jobParams);
    qDeleteAll(d_viewGroups);
}

Line::~Line()
{
    qDeleteAll(d_commands);
}

Routine::~Routine()
{
    qDeleteAll(d_lines);
}
