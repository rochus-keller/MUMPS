%G      ;GENERAL GLOBAL UTILITY (LIST, ETC) @SMB@
0       S %GIOD=0,%RET="^%G",$ZT="%ER^%G"
1       D ^%G1 G KQ:"^"[% S %("X")="G W" D GO G 1
%ER     U 0 W !,$ZE,! S $ZT="%ER^%G" G 1
        Q
        -
ZN      S %ZN=%N_%SS,%G=%ZN_""""")",%ZL=$L(%ZN),%DF=1
ZN1     S %G=$ZO(@%G) G POP:$E(%G,1,%ZL)'=%ZN S %D=@%G D:%CHK CHK X %("X") Q:%Q  G ZN1
        -
IO      S %QTY=2,%DEF=0 D ^%IOS G KQ:'$D(%IOD) S $ZE="TRAP^%G",%GIOD=%IOD K %DTY,%IOD D 1 S $ZE="" Q
        -
CHK     I %D?.E1C.E F %I=0:1:31,127 I %D[$C(%I) G REMOV
        Q
REMOV   U 0 W !,%G," = ",%D,!?5,"Control character ",%I," in position ",$F(%D,$C(%I))-1
        S %D="Control characters in data, data not transferred" W !?5,%D Q
GO      S %Q=0 U %GIOD F %GP=1:1 Q:'$D(%(0,%GP))  D GP Q:%Q
        U 0 Q
GP      S %GN=%(0,%GP,"S") D:%GN'="^" G:$D(@%GN) Q:%Q
GP1     Q:%GN=%(0,%GP)  S %GN=$ZS(^UTILITY($J,0,%GN)) Q:%GN=""!(%GN]%(0,%GP))
        D G Q:%Q  G GP1
        -
G       Q:'$D(@%GN)  U 0 W:'%("X")["EDIT" !,"Now copying global : ",%GN U %GIOD S %C=$V(83,$J)#2,%L=0,%SS=""
        S %G=$ZR,%DF=$D(@%G),%N=%G_"(",%D=@%G S:'$D(%CHK) %CHK=0 D:%CHK CHK X:'%("P") %("X") Q:%Q
L       S %L=%L+1 G POP:%L>%("M")&(%("M")>-1),ZN:%L>%("C")&%("D")&(%("M")<0) S %P=1
P       S %S=$S(%L'>%("C"):%(%L,%P,"S"),1:""),%DF=0
        D Q I %S]"" S %DF=$D(@(%N_%SS_%SQ_")")) G NX1:%DF
NX      I $D(%(%L,%P)),%S=%(%L,%P) G P1
        S %S=$ZS(@(%N_%SS_%SQ_")")) G P1:%S="" I $D(%(%L,%P)) D T G P1:%X
        S %DF=$D(^(%S))
NX1     I '$D(%(%L,%P,"C")) D N Q:%Q  G PUSH:%DF\10,NX
        D Q S %D=$S(%DF#10:^(%S),1:""),%G=%N_%SS_%SQ_")"
        I @%(%L,%P,"C") D N0 Q:%Q  G PUSH:%DF\10
        G NX
        -
P1      S %P=%P+1 G P:$D(%(%L,%P,"S"))
POP     Q:%L=1  S %L=%L-1,%P=%L(%L),%S=%L(%L,0),%SS=%L(%L,1),%SQ=%L(%L,2) G NX
        -
PUSH    S %L(%L)=%P,%L(%L,0)=%S,%L(%L,1)=%SS,%L(%L,2)=%SQ,%SS=%SS_%SQ_"," G L
        -
T       I %C S %X=%S]%(%L,%P) Q
        K %X S (%X(%S),%X(%(%L,%P)))="",%X=$O(%X(""))'=%S Q
        -
N       D Q
N0      Q:%("P")>%L  I %DF#10=0 Q:%("D")
        S %D=$S(%DF#10:^(%S),1:""),%G=%N_%SS_%SQ_")" D:%CHK CHK X %("X") Q
        -
W       I %DF#10 W !,$ZR," = ",%D Q
        W !,$ZR Q
        -
Q       S %SQ=%S,%X=0
Q1      S %X=$F(%SQ,"""",%X) I %X S %SQ=$E(%SQ,1,%X-1)_$E(%SQ,%X-1,999)
        I $L(%S)>27 K %X S %X(%S)="" S:$O(%X(" "))'="" %SQ=""""_%SQ_"""" Q
        I %SQ?1N.N1"E".E S %SQ=""""_%SQ_"""" Q
        S:+%SQ'=%SQ %SQ=""""_%SQ_"""" Q
        -
KQ      K %,%C,%D,%DF,%G,%GN,%GP,%L,%N,%P,%Q,%S,%SQ,%SS,%X,%ZL,%ZN
KQ1     U 0 I $D(%GIOD),%GIOD'=$I,%GIOD C %GIOD
        K %GIOD Q
        -
TRAP    U 0 W !,$ZE G KQ1
CHKHLP  W !,?5,"Answer ""Y[ES]"" if you want to include a check for"
        W !,?5,"control characters in the global data. If  included"
        W !,?5,"each record containing control characters   will be"
        W !,?5,"displayed on your terminal so that they can be  re-"
        W !,?5,"stored manually. The control character check   will"
        W !,?5,"impact the speed of global save." Q
