%P      ;7-Dec-81 ;UTILITY ;EDITOR ;FRONT END FOR EDT ON VAX ;JHM
        W # I '$D(%EDT(10)) S %EDT(10)="SETLIB^%P"
        K LOAD S LOAD=0
Q0      W !,"Program > " R NM I NM=""!(NM="^") Q
        I NM'["." S NM=NM_".SOU"
        S PFILE=$ZSE("SRC$:"_NM) I PFILE'="" G EDIFIL
        S ROUT=$P(NM,".",1)
Q1      W !,"File not found",!,"Create new file SRC$:",NM," ? <Y> " R A
        I A?1"Y"."ES"!(A?1"y"."es")!(A="") G NEWFIL
        I A?1"N"."O"!(A?1"n"."o") G Q0
        I A="^" Q
        W !,"Answer yes or no" G Q1
NEWFIL  R !,"System > ",SYS G Q1:SYS="^"
Q2      R !,"Package > ",PK G NEWFIL:PK="^"
Q3      R !,"Function > ",FUN G Q2:FUN="^"
Q4      R !,"Initials > ",INI G Q3:INI="^"
        S $ZT="NEWERR",PFILE="SRC$:"_NM O PFILE:NEW U PFILE S %ZIOD=$ZIO
        W ROUT_$C(9)_";" D ^%D W " ;"_SYS_" ;"_PK_" ;"_FUN_" ;"_INI,!
        W $C(9)_";Last edit:  *****",!
        W $C(26) C PFILE S PFILE=%ZIOD G EDIFIL
NEWERR  S ZE=$ZE U 0 S $ZE=""
        W !,"Error creating new file ",PFILE,!,"$ZE=",ZE Q
EDIFIL  S %EDT(0)="COM^%P",%EDT="LOAD^%P"
        S %EDT(1)="XEC^%P"
        S $ZT="EDIERR^%P",PFILE=$P(PFILE,";",1)
        U 0:NOCENABLE
        S A=$ZC(EDT,PFILE,"EDT$INI")
        S B=$ZC U 0:CENABLE W #
        I +A O PFILE U PFILE S F=$ZIO C PFILE W !,"File saved: ",F,!,"Lines,Characters ",$P(A,",",1,2)
        E  W !,"No file saved"
        S $ZT="FINIERR^%P"
        I LOAD F I=1:1:LOAD O LOAD(LOAD) C LOAD(LOAD):DELETE
        G EXIT
EDIERR  I $ZT'="EDIERR^%P" ZQ
        U 0 S ZE=$ZE,$ZE=""
        W !,"Error during ZCALL",!,"$ZE = ",ZE Q
FINIERR I $ZT'="FINIERR^%P" ZQ
        S ZE=$ZE,$ZE="" W !,"Error deleting scratch files",!,"$ZE = ",ZE Q
COM     S $ZT="COMERR^%P" D @%EDT(10)
        S PNAM=$E(PFILE,$F(PFILE,"]"),9999),FILE="EDT$SCRATCH"
        U 0 W #,"Compiling program ",PNAM,!,"with Library:",!
        F I=1:1 Q:'$D(LIB(I))  W !,I,?5,LIB(I)
        K PCFLG D ^%PCOMP
        I BD H 10
        O FILE C FILE:DEL
        Q
COMERR  I $ZT'="COMERR^%P" ZQ
        U 0 S ZE=$ZE,$ZE=""
        W !,"Error during compile",!,"$ZE=",ZE H 10 Q
LOAD    U 0 W #
LQ1     U 0 W !,"Routine ? > " R NM
        I NM=""!(NM="^") S EDTFILE="" Q
        S $ZT="LERR^%P" X "ZL @NM"
        S $ZT="LFERR^%P"
        S TEMP="SCRATCH.TMP"
        O TEMP:NEW U TEMP S LOAD=LOAD+1,LOAD(LOAD)=$ZIO
        U 0 W !,"Loading routine...",! X "ZL @NM U TEMP ZP"
        C TEMP S EDTFILE=LOAD(LOAD) Q
LERR    I $ZT'="LERR^%P" ZQ
        S ZE=$ZE,$ZE="" U 0 W !,"Error loading routine ",NM,!,"$ZE = ",ZE G LQ1
LFERR   I $ZT'="LFERR^%P" ZQ
        S ZE=$ZE,$ZE="" U 0 W !,"File error ",ZE G LQ1
EXIT    Q
XEC     S $ZT="CMDERR^%P" U 0 W #,"Halt command exits",!
XEC2    U 0 W !,">" R CMD G XEC2:CMD=""
        I $E("HALT",1,$L(CMD))=CMD Q
        X CMD G XEC2
CMDERR  I $ZT'="CMDERR^%P" ZQ
        S ZE=$ZE,$ZE="" U 0 W !,"Error: ",ZE G XEC2
SETLIB  K LIB S LIB=1,LIB(1)="COM" Q
