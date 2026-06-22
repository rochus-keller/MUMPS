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

#include "MpsNode.h"
using namespace Mps;


Node::Node()
    : d_hasValue(false)
{
}

Node::~Node()
{
    qDeleteAll(d_children);
}

void Node::setValue(const QByteArray& val)
{
    d_value = val;
    d_hasValue = true;
}

void Node::clearValue()
{
    d_value.clear();
    d_hasValue = false;
}

Node* Node::getOrCreate(const QByteArray& subscript)
{
    QMap<QByteArray, Node*>::iterator it = d_children.find(subscript);
    if( it != d_children.end() )
        return it.value();

    Node* child = new Node();
    d_children.insert(subscript, child);
    insertKey(subscript);
    return child;
}

Node* Node::get(const QByteArray& subscript) const
{
    QMap<QByteArray, Node*>::const_iterator it = d_children.find(subscript);
    if( it != d_children.end() )
        return it.value();
    return 0;
}

void Node::removeChild(const QByteArray& subscript)
{
    QMap<QByteArray, Node*>::iterator it = d_children.find(subscript);
    if( it != d_children.end() )
    {
        delete it.value();
        d_children.erase(it);
        removeKey(subscript);
    }
}

void Node::removeAllChildren()
{
    qDeleteAll(d_children);
    d_children.clear();
    d_orderedKeys.clear();
}

int Node::data() const
{
    int result = 0;
    if( d_hasValue )
        result += 1;
    if( !d_children.isEmpty() )
        result += 10;
    return result;
}

QByteArray Node::order(const QByteArray& subscript, int direction) const
{
    if( d_orderedKeys.isEmpty() )
        return QByteArray();

    if( subscript.isEmpty() )
    {
        if( direction >= 0 )
            return d_orderedKeys.first();
        else
            return d_orderedKeys.last();
    }

    int idx = findKeyIndex(subscript);

    if( direction >= 0 )
    {
        if( idx >= 0 )
        {
            if( idx + 1 < d_orderedKeys.size() )
                return d_orderedKeys[idx + 1];
            return QByteArray();
        }
        for( int i = 0; i < d_orderedKeys.size(); i++ )
        {
            if( Collation::compare(d_orderedKeys[i], subscript) > 0 )
                return d_orderedKeys[i];
        }
        return QByteArray();
    } else
    {
        if( idx >= 0 )
        {
            if( idx - 1 >= 0 )
                return d_orderedKeys[idx - 1];
            return QByteArray();
        }
        for( int i = d_orderedKeys.size() - 1; i >= 0; i-- )
        {
            if( Collation::compare(d_orderedKeys[i], subscript) < 0 )
                return d_orderedKeys[i];
        }
        return QByteArray();
    }
}

Node* Node::descend(const QList<QByteArray>& subscripts) const
{
    const Node* current = this;
    for( int i = 0; i < subscripts.size(); i++ )
    {
        current = current->get(subscripts[i]);
        if( !current )
            return 0;
    }
    return const_cast<Node*>(current);
}

Node* Node::descendOrCreate(const QList<QByteArray>& subscripts)
{
    Node* current = this;
    for( int i = 0; i < subscripts.size(); i++ )
        current = current->getOrCreate(subscripts[i]);
    return current;
}

void Node::insertKey(const QByteArray& key)
{
    int lo = 0;
    int hi = d_orderedKeys.size();
    while( lo < hi )
    {
        int mid = (lo + hi) / 2;
        if( Collation::compare(d_orderedKeys[mid], key) < 0 )
            lo = mid + 1;
        else
            hi = mid;
    }
    d_orderedKeys.insert(lo, key);
}

void Node::removeKey(const QByteArray& key)
{
    int idx = findKeyIndex(key);
    if( idx >= 0 )
        d_orderedKeys.removeAt(idx);
}

int Node::findKeyIndex(const QByteArray& key) const
{
    int lo = 0;
    int hi = d_orderedKeys.size() - 1;
    while( lo <= hi )
    {
        int mid = (lo + hi) / 2;
        int cmp = Collation::compare(d_orderedKeys[mid], key);
        if( cmp == 0 )
            return mid;
        if( cmp < 0 )
            lo = mid + 1;
        else
            hi = mid - 1;
    }
    return -1;
}

SymbolTable::SymbolTable()
{
}

SymbolTable::~SymbolTable()
{
    qDeleteAll(d_vars);
}

Node* SymbolTable::getOrCreate(const QByteArray& name)
{
    QMap<QByteArray, Node*>::iterator it = d_vars.find(name);
    if( it != d_vars.end() )
        return it.value();

    Node* node = new Node();
    d_vars.insert(name, node);
    return node;
}

Node* SymbolTable::get(const QByteArray& name) const
{
    QMap<QByteArray, Node*>::const_iterator it = d_vars.find(name);
    if( it != d_vars.end() )
        return it.value();
    return 0;
}

void SymbolTable::remove(const QByteArray& name)
{
    QMap<QByteArray, Node*>::iterator it = d_vars.find(name);
    if( it != d_vars.end() )
    {
        delete it.value();
        d_vars.erase(it);
    }
}

Node* SymbolTable::detach(const QByteArray& name)
{
    QMap<QByteArray, Node*>::iterator it = d_vars.find(name);
    if( it != d_vars.end() )
    {
        Node* node = it.value();
        d_vars.erase(it);
        return node;
    }
    return 0;
}

void SymbolTable::reattach(const QByteArray& name, Node* node)
{
    QMap<QByteArray, Node*>::iterator it = d_vars.find(name);
    if( it != d_vars.end() )
        delete it.value();
    d_vars.insert(name, node);
}

bool SymbolTable::contains(const QByteArray& name) const
{
    return d_vars.contains(name);
}

QList<QByteArray> SymbolTable::names() const
{
    return d_vars.keys();
}

void SymbolTable::clear()
{
    qDeleteAll(d_vars);
    d_vars.clear();
}
