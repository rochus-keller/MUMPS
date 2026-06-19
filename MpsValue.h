#ifndef MPSVALUE_H
#define MPSVALUE_H

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

namespace Mps {

class Value {
public:
    Value();
    explicit Value(const QByteArray& str);
    explicit Value(double num);
    explicit Value(int num);

    const QByteArray& str() const { return d_str; }
    bool isEmpty() const { return d_str.isEmpty(); }

    double toNumber() const;
    bool toBool() const;

    static QByteArray numToCanonical(double val);
    bool isCanonicalNumeric() const;

    Value add(const Value& other) const;
    Value subtract(const Value& other) const;
    Value multiply(const Value& other) const;
    Value divide(const Value& other) const;
    Value intDivide(const Value& other) const;
    Value modulo(const Value& other) const;
    Value negate() const;
    Value positive() const;

    Value concatenate(const Value& other) const;

    bool numericLess(const Value& other) const;
    bool numericGreater(const Value& other) const;
    bool equals(const Value& other) const;
    bool contains(const Value& other) const;
    bool follows(const Value& other) const;
    bool patternMatch(const QByteArray& pattern) const;

    Value logicalAnd(const Value& other) const;
    Value logicalOr(const Value& other) const;
    Value logicalNot() const;

private:
    QByteArray d_str;
};

}

#endif // MPSVALUE_H
