PATFL1  ;YZH;23-JUN-80;CREATE NEW PATCHES IN ^SYS(0,"PATCH") GLOBAL
        W !,*7,"This subroutine should be run using the autopatch utility ^AUPAT.",!,*7 Q
START   S NUMCT=0,STFLG="" R !!,"Patch number ? > ",ANS I ANS=""!(ANS="^") G END
        I ANS["?" D HLP1^PATFL5 G START
        I ANS'?1N.ANP D IV G START
        I $D(^SYS(0,"PATCH",ANS)) W !!,?3,"Patch #",ANS," already defined!" G START
        S PATNM=ANS
PADAT   R !!,"Patch date  [DD-MMM-YY]  ?  > ",ANS G:ANS="^" START
        I ANS="" S %NP="" D ^%D W %DAT1 S PADAT=%DAT1 K %DAT1 G TITLE
        I ANS["?" D HLP2^PATFL5 G PADAT
        I ANS'?1N.N1"-"3A1"-"2N D IV G PADAT
        S PADAT=ANS,MONTH=$P(ANS,"-",2),DAY=$P(ANS,"-",1)
        I $T(MONTH)'[MONTH!(DAY<1)!(DAY>31)!($P(ANS,"-",3)<80) D IV G PADAT
TITLE   R !!,"Patch title ? > ",ANS I ANS=""!(ANS="^") G START
        I ANS["?" D HLP3^PATFL5 G TITLE
        I $L(ANS)>245 W !!,"Patch title too long" G TITLE
        S TITLE=ANS
        W !!,"Now you can start to enter your patch data"
MODUL   R !!,"Module name ? > ",ANS I ANS=""!(ANS="^") G TITLE:$D(STFLG),START
        I ANS["?" W !!,"Enter one of the following:" S ANS=""
        S SS="",TAB=$P($T(TAB),";;",2) F I=1:1 S MODUL=$P(TAB,"/",I) Q:MODUL=""  I $E(MODUL,1,$L(ANS))=ANS W:(SS'="S"&(SS'="")) !?3,SS S SS=$S(SS="":MODUL,1:"S") W:SS="S" !?3,MODUL
        D:SS="" IV I SS=""!(SS="S") G MODUL
        W $E(SS,$L(ANS)+1,99)
ADOFF   R !!,"Address offset ? > ",ANS I ANS=""!(ANS="^") G MODUL
        I ANS["?" D HLP5^PATFL5 G ADOFF
        I ANS'?.N!(ANS[8)!(ANS[9)!(ANS#2) D IV G ADOFF
        S ADOFF=ANS
OLDCO   R !!,"Old contents ? > ",ANS I ANS=""!(ANS="^") G ADOFF
        I ANS["?" D HLP6^PATFL5 G OLDCO
        I ANS'?.N!(ANS[8)!(ANS[9)&(ANS'?1"X"."X") D IV G OLDCO
        S OLDCO=ANS
NEWCO   K DIR R !!,"New contents ? > ",ANS I ANS=""!(ANS="^") G OLDCO
        I ANS["?" D HLP7^PATFL5 G NEWCO
        I ANS["+" D MDBAS G:$D(DIR) NEWCO G CONT
        I ANS'?.N!(ANS[8)!(ANS[9) D IV G NEWCO
CONT    S NEWCO=ANS,NUMCT=NUMCT+1
        I $D(STFLG) S ^SYS(0,"PATCH",PATNM,0)=0_"/"_PADAT_"/"_TITLE K STFLG
        S ^SYS(0,"PATCH",PATNM,NUMCT)=SS_"/"_ADOFF_"/"_OLDCO_"/"_NEWCO
        S %OD=ADOFF D ^%OD S %OD=%OD+2,%DO=%OD D ^%DO S ADOFF=%DO
        W !!,"Address offset = ",ADOFF G OLDCO
MDBAS   S MDBAS=$P(ANS,"+",1),MDOFF=$P(ANS,"+",2)
        F I=1:1 S MODNM=$P(TAB,"/",I) Q:MODNM=""  I MDBAS=MODNM G MDOFF
        S DIR="" D IV Q
MDOFF   I MDOFF'?1N.N!(MDOFF[8)!(MDOFF[9) S DIR="" D IV Q
        Q
IV      W !!,?7,"Incorrect response, enter ""?"" for help",! Q
END     K %DAT1,%DO,%OD,ADOFF,ANS,I,MODUL,NEWCO,NUMCT,OLDCO,PADAT,PATNM,SS,STFLG,TAB,TITLE,MDBAS,MDOFF,MODNM
        S %NOPAUSE=1 Q
MONTH   ;;-JAN-FEB-MAR-APR-MAY-JUN-JUL-AUG-SEP-OCT-NOV-DEC
TAB     ;;VECTOR/SYSTAB/EXEC/MUMPS/PATCH/INTERP/SUBRS/EVAL/SYMBOL/GLOBAL/ALLOC/ZCALL/KEXEC/DISK/EMT/KIOD/KSPOOL/DSMXDT/MTD/EBCDIC/JRNL/SDP/DMC/JOBCOM/DDP/USRDRV/DDBTAB/CONFIG/BOOTDK/TU58/RX02/BISYNC
