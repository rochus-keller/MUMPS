#ifndef MPSNODE_H
#define MPSNODE_H

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

#include <QByteArray>
#include <QMap>
#include "MpsCollation.h"

namespace Mps {

class Node {
public:
    Node();
    ~Node();

    bool hasValue() const { return d_hasValue; }
    const QByteArray& value() const { return d_value; }
    void setValue(const QByteArray& val);
    void clearValue();

    bool hasChildren() const { return !d_children.isEmpty(); }
    int childCount() const { return d_children.size(); }

    Node* getOrCreate(const QByteArray& subscript);
    Node* get(const QByteArray& subscript) const;
    void removeChild(const QByteArray& subscript);
    void removeAllChildren();

    int data() const;
    QByteArray order(const QByteArray& subscript, int direction = 1) const;

    Node* descend(const QList<QByteArray>& subscripts) const;
    Node* descendOrCreate(const QList<QByteArray>& subscripts);

private:
    QByteArray d_value;
    bool d_hasValue;
    QMap<QByteArray, Node*> d_children;
    QList<QByteArray> d_orderedKeys; // keys in MUMPS collation order

    void insertKey(const QByteArray& key);
    void removeKey(const QByteArray& key);
    int findKeyIndex(const QByteArray& key) const;
};

class SymbolTable {
public:
    SymbolTable();
    ~SymbolTable();

    Node* getOrCreate(const QByteArray& name);
    Node* get(const QByteArray& name) const;
    void remove(const QByteArray& name);
    bool contains(const QByteArray& name) const;
    QList<QByteArray> names() const;
    void clear();

private:
    QMap<QByteArray, Node*> d_vars;
};

}

#endif // MPSNODE_H
