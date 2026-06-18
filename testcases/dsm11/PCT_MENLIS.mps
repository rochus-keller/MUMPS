%MENLIS ;FDN;11-JUN-80;LIST MENU GLOBAL
        S $ZE="ERR^%MENLIS"
%ST     S %QTY=2 K %DEF D ^%IOS G:'$D(%IOD) %EXIT
        S %X="^%MENU(""A"")",%M=0,%L=0 K %C
LOOP    U %IOD W # F %I=1:1 S %X=$ZN(@%X) Q:%X=-1  D LSTNOD
        W # G %EXIT
LSTNOD  D GETLEV D FORMAT Q
GETLEV  S %M=%L,%K="",%S=$E(%X,$F(%X,"("),$L(%X)-2)
        F %L=1:1 S %K=$P(%S,",",%L) Q:%K=""
        S %L=%L-1,%K=$P(%S,",",%L)
        S:'$D(%C(%L)) %C(%L)=0 S %C(%L)=%C(%L)+1
        I %M>%L F %J=%L+1:1:%M S %C(%J)=0
        Q
FORMAT  S %D=@%X,%G=%L-1*4
        U %IOD W:$Y>60 # W !,?%G,%C(%L),".",?%G+4,%K
        S %R=$P(%D,"]",1),%H=$P(%D,"]",2),%T=$P(%D,"]",3),%P=$P(%D,"]",4),%A=$P(%D,"]",5),%B=$P(%D,"]",6)
        G RTFRM:'(%R="") W "   = Menu",!!,?%G+4,%T,":",!
        W:$Y>60 # D PRE W ! F %N=1:1 S %C=$P(%H,"\",%N) Q:%C=""  W ?%G+8,%C,!
        W:$Y>60 # D POST W !,?%G+4,%P," >",!! Q
RTFRM   W "  = routine  ",%R,!!
        F %N=1:1 S %C=$P(%H,"\",%N) Q:%C=""  W:$Y>60 # W ?%G+4,%C,!
        D PRE,POST Q
PRE     W:%A'="" !,?%G+4,"Pre-action = ",%A,! Q
POST    W:%B'="" !?%G+4,"Post-action = ",%B,! Q
ERR     U 0 I $ZE?1"<INRPT".E W !?5,*7,"Unexpected interrupt",!
        E  W !,$ZE,!
%EXIT   U 0 I $D(%IOD) C:%IOD'=$I %IOD
        W !!,"Menu Global listing completed",!
        K %K,%I,%X,%M,%L,%C,%N,%S,%D,%T,%P,%R,%H,%A,%B,%G,%O,%DTY,%IOD
        Q
