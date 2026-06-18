%G1     ;GLOBAL READ @SMB@
1       S %DIR=0 D R K %DIR G KQ
R       K % W !,"Global ^" R %,! Q:"^"[%  I %="?" D ^%G2 G R
        S QQ=", probably forgot quotes in subscript."
        I %="*D"!(%="??") D GETDIR,DIS G R
        I %?1"?"1A.NA!(%?1"?%".NA) D GETDIR,DISP G R
        S %WRT=1 D GO G R:%ER D GETDIR:%GD Q
        -
GO      S %("M")=-1,(%("C"),%("P"))=0,%("D")=1,(%P,%CP,%GD,%L,%ER)=0 W:%WRT ?8
GN      D NM I $E(%N,2)'="%",$E(%N,2)'="[",$E(%N,2)'?.A,%N'="^ " G ER2
        G GN:%C=" "
L       G P1:")"[%C,ER:"(,"'[%C S %L=%L+1,%("P")=%L,%P=0
P       S %P=%P+1 Q:$E(%,%CP+1)=""  S %("C")=%L D E,SET Q:%ER
        I %C=":" S %(%L,%P)=$C(127) D E S:%O]"" @("%(%L,%P)="_%O)
        I %C=":" D E S:%O]"" %(%L,%P,"C")=%O
        G P:%C=" ",L:")"'[%C
P1      Q:%C=""  G ER:$E(%,%CP+1)]"" S %("M")=%L,%("D")=0 Q
        -
E       S %F=%CP+1,%PR=0
E1      D N I %PR=0!(%C="")," ),:"[%C S %O=$E(%,%F,%CP-1) Q
        I "()"[%C S %PR=%PR+$S(%C="(":1,1:-1) G E1
        G E1:%C'=""""
F       D N G E1:""""[%C,F
        -
N       S %CP=%CP+1,%C=$E(%,%CP) W:%WRT %C Q
        -
NM      ;
        I $E(%)="(" S %4N=$E($ZR,2,999) S:$E(%4N,$L(%4N))=")" %4N=$E(%4N,1,$L(%4N)-1) S %=%4N_$E(%,2,999) K %4N
        I $E(%)="@" S %4N=@$P(%,"@",2),%=$S($E(%4N,$L(%4N))'=")":%4N_$P(%,"@",3,999),1:$E(%4N,1,$L(%4N)-1)_$S($P(%,"@",3,999)="":"",
1:","_$E($P(%,"@",3,999),2,999)))
        D N0 S %P=%P+1,%(0,%P,"S")=%N
        I %C="*" S %(0,%P)=%N_"zzzzzzzz",%GD=1 D N Q
        I %C'=":",%C'="-" S %(0,%P)=%N Q
        S %GD=1 D N0 I %N="" S %(0,%P)="zzzzzzzzz" Q
        S %(0,%P)=%N Q
N0      D UP S %N="^" I %C="%" S %N="^%" D N
N1      I %C?1NA!$F("[,%]""",%C)!(%N="^"!($E(%N,$L(%N))="]")&(%C=" ")),%C'="" S %N=%N_%C D N G N1
        Q
UP      D N G UP:%C="^" Q
        -
ER      S %ER=1 W:%WRT " ?",*7 Q
        -
ER2     W " - Global name must begin with alphabetic or ""%""",*7 S %ER=2 Q
        -
KQ      K %C,%CP,%ER,%F,%GD,%L,%N,%O,%P,%PR,%WRT,%IEX Q
        -
DIS     S %N="" F %I=1:1 S %N=$ZS(^UTILITY($J,0,%N)) Q:%N=""  W:%I#8=1 ! W ?%I-1#8*10,%N
        K %I,%N Q
DISP    S %N="^"_$E(%,2,$L(%)-1)_$C($A(%,$L(%))-1)_"z",%S="^"_$E(%,2,99)
        F %I=1:1 S %N=$ZS(^UTILITY($J,0,%N)) Q:$E(%N,1,$L(%S))'=%S  W:%I#8=1 ! W ?%I-1#8*10,%N
        K %I,%N,%S Q
        -
GETDIR  Q:%DIR  S %GZE=$ZT,$ZT="TRAP^%G1" O 63::1 G GET:$T W " <View buffer wait>" O 63
GET     K ^UTILITY($J,0)
        S %UCI=$P($ZU(""),","),%SN=$P($ZU(""),",",2),%STB=$V(44)
        S %MM=$V(%SN*($V(%STB+34)#256)+$V(%STB+12)+2)
        S %BLK=$V(%UCI-1*20+4,%MM)#256*65536+$V(%UCI-1*20+2,%MM)
        S %VS="S"_%SN
        S %CT=0
%VIEW   V %BLK:%VS
        S %END=$V(1022,0),%NAM="",%PT=0
%NXT    G %PTR:%END'>%PT
%C      S %A=$V(%PT,0)#256,%PT=%PT+1,%NAM=%NAM_$C(%A\2) G %C:%A#2
        S ^UTILITY($J,0,"^"_%NAM)=""
        S %CT=%CT+1,%PT=%PT+8,%NAM="" G %NXT
%PTR    S %BLK=$V(1016,0)#256*65536+$V(1014,0) I %BLK G %VIEW
%PTR1   C 63 K %A,%CT,%NAM,%PT,%BLK,%END,%GZE,%LST,%STB,%UCI,%UCN,%UCIN S %DIR=1 Q
TRAP    U 0 W !,$ZE G %PTR1
        -
SET     S $ZT="TRAP1^%G1",%(%L,%P)=$C(127) S:%O]"" @("%O="_%O),%(%L,%P)=%O S %(%L,%P,"S")=%O Q
TRAP1   U 0 I $ZE["UNDEF" W !!,*7,"Global undefined",QQ,!! D KQ
        E  I $ZE["SYNTX" W !!,*7,"Syntax error",QQ,!! D KQ
        E  I $ZE["INRPT" W !,$ZE,! D KQ
        E  W !,$ZE,!
        S %ER=1 Q
        -
GTO     D R G KQ
        -
INT     S %DIR=0 D INT1 K %DIR Q
INT1    S %P=% K % S %=%P,%WRT=0 D GO I %ER K % S %="" G KQ
        D GETDIR:%GD G KQ
