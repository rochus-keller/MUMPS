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

#include "MpsValue.h"
#include <qmath.h>
using namespace Mps;

Value::Value()
{
}

Value::Value(const QByteArray& str)
    : d_str(str)
{
}

Value::Value(double num)
    : d_str(numToCanonical(num))
{
}

Value::Value(int num)
    : d_str(QByteArray::number(num))
{
}

double Value::toNumber() const
{
    if( d_str.isEmpty() )
        return 0.0;

    int pos = 0;
    const int len = d_str.size();
    double sign = 1.0;

    if( pos < len && (d_str[pos] == '+' || d_str[pos] == '-') )
    {
        if( d_str[pos] == '-' )
            sign = -1.0;
        pos++;
    }

    bool hasDigits = false;
    double intPart = 0.0;

    while( pos < len && d_str[pos] >= '0' && d_str[pos] <= '9' )
    {
        intPart = intPart * 10.0 + (d_str[pos] - '0');
        hasDigits = true;
        pos++;
    }

    double fracPart = 0.0;
    double fracDiv = 1.0;

    if( pos < len && d_str[pos] == '.' )
    {
        pos++;
        while( pos < len && d_str[pos] >= '0' && d_str[pos] <= '9' )
        {
            fracPart = fracPart * 10.0 + (d_str[pos] - '0');
            fracDiv *= 10.0;
            hasDigits = true;
            pos++;
        }
    }

    if( !hasDigits )
        return 0.0;

    return sign * (intPart + fracPart / fracDiv);
}

bool Value::toBool() const
{
    return toNumber() != 0.0;
}

QByteArray Value::numToCanonical(double val)
{
    if( val == 0.0 )
        return "0";

    if( val == qFloor(val) && qAbs(val) < 1e15 )
    {
        qlonglong ival = (qlonglong)val;
        return QByteArray::number(ival);
    }

    QByteArray result = QByteArray::number(val, 'g', 15);

    if( result.contains('.') )
    {
        int i = result.size() - 1;
        while( i > 0 && result[i] == '0' )
            i--;
        if( result[i] == '.' )
            i--;
        result.truncate(i + 1);
    }

    if( result == "-0" )
        return "0";

    if( result.startsWith("0.") )
        result = result.mid(1);
    else if( result.startsWith("-0.") )
        result = "-" + result.mid(2);

    return result;
}

bool Value::isCanonicalNumeric() const
{
    if( d_str.isEmpty() )
        return false;

    double num = toNumber();
    return numToCanonical(num) == d_str;
}

Value Value::add(const Value& other) const
{
    return Value(toNumber() + other.toNumber());
}

Value Value::subtract(const Value& other) const
{
    return Value(toNumber() - other.toNumber());
}

Value Value::multiply(const Value& other) const
{
    return Value(toNumber() * other.toNumber());
}

Value Value::divide(const Value& other) const
{
    double divisor = other.toNumber();
    if( divisor == 0.0 )
        return Value(0);
    return Value(toNumber() / divisor);
}

Value Value::intDivide(const Value& other) const
{
    double divisor = other.toNumber();
    if( divisor == 0.0 )
        return Value(0);
    double result = toNumber() / divisor;
    if( result >= 0.0 )
        result = qFloor(result);
    else
        result = qCeil(result);
    return Value(result);
}

Value Value::modulo(const Value& other) const
{
    double divisor = other.toNumber();
    if( divisor == 0.0 )
        return Value(0);
    double a = toNumber();
    double b = divisor;
    double idiv;
    if( a / b >= 0.0 )
        idiv = qFloor(a / b);
    else
        idiv = qCeil(a / b);
    return Value(a - idiv * b);
}

Value Value::negate() const
{
    return Value(-toNumber());
}

Value Value::positive() const
{
    return Value(toNumber());
}

Value Value::concatenate(const Value& other) const
{
    return Value(d_str + other.d_str);
}

bool Value::numericLess(const Value& other) const
{
    return toNumber() < other.toNumber();
}

bool Value::numericGreater(const Value& other) const
{
    return toNumber() > other.toNumber();
}

bool Value::equals(const Value& other) const
{
    return d_str == other.d_str;
}

bool Value::contains(const Value& other) const
{
    if( other.d_str.isEmpty() )
        return true;
    return d_str.contains(other.d_str);
}

bool Value::follows(const Value& other) const
{
    return d_str > other.d_str;
}

bool Value::patternMatch(const QByteArray& pattern) const
{
    Q_UNUSED(pattern);
    return false;
}

Value Value::logicalAnd(const Value& other) const
{
    return Value(QByteArray(toBool() && other.toBool() ? "1" : "0"));
}

Value Value::logicalOr(const Value& other) const
{
    return Value(QByteArray(toBool() || other.toBool() ? "1" : "0"));
}

Value Value::logicalNot() const
{
    return Value(QByteArray(toBool() ? "0" : "1"));
}
