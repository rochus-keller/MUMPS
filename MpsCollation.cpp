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

#include "MpsCollation.h"
#include <qmath.h>
using namespace Mps;

double Collation::toNumber(const QByteArray& str)
{
    if( str.isEmpty() )
        return 0.0;

    int pos = 0;
    const int len = str.size();
    double sign = 1.0;

    if( pos < len && (str[pos] == '+' || str[pos] == '-') )
    {
        if( str[pos] == '-' )
            sign = -1.0;
        pos++;
    }

    bool hasDigits = false;
    double intPart = 0.0;
    while( pos < len && str[pos] >= '0' && str[pos] <= '9' )
    {
        intPart = intPart * 10.0 + (str[pos] - '0');
        hasDigits = true;
        pos++;
    }

    double fracPart = 0.0;
    double fracDiv = 1.0;
    if( pos < len && str[pos] == '.' )
    {
        pos++;
        while( pos < len && str[pos] >= '0' && str[pos] <= '9' )
        {
            fracPart = fracPart * 10.0 + (str[pos] - '0');
            fracDiv *= 10.0;
            hasDigits = true;
            pos++;
        }
    }

    if( !hasDigits )
        return 0.0;

    return sign * (intPart + fracPart / fracDiv);
}

QByteArray Collation::numToCanonical(double val)
{
    if( val == 0.0 )
        return "0";

    if( val == qFloor(val) && qAbs(val) < 1e15 )
    {
        qlonglong ival = (qlonglong)val;
        return QByteArray::number(ival);
    }

    QByteArray result = QByteArray::number(val, 'f', 18);

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

bool Collation::isCanonicalNumeric(const QByteArray& str)
{
    if( str.isEmpty() )
        return false;

    double num = toNumber(str);
    return numToCanonical(num) == str;
}

int Collation::compare(const QByteArray& a, const QByteArray& b)
{
    if( a == b )
        return 0;

    if( a.isEmpty() )
        return -1;
    if( b.isEmpty() )
        return 1;

    const bool aNum = isCanonicalNumeric(a);
    const bool bNum = isCanonicalNumeric(b);

    if( aNum && !bNum )
        return -1;
    if( !aNum && bNum )
        return 1;

    if( aNum && bNum )
    {
        const double da = toNumber(a);
        const double db = toNumber(b);
        if( da < db )
            return -1;
        if( da > db )
            return 1;
        return 0;
    }

    if( a < b )
        return -1;
    if( a > b )
        return 1;
    return 0;
}
