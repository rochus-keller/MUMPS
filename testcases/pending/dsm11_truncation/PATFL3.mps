PATFL3  ;YZH;23-JUN-80;EDIT PATCHES FROM ^SYS(0,"PATCH") GLOBAL
        W !,*7,"This subroutine should be run using the autopatch utility ^AUPAT.",!,*7 Q
START   R !!,"Edit patch number ? > ",ANS I ANS=""!(ANS="^") G END
        I ANS["?" D HLP8^PATFL5 G START
        I ANS'?1N.ANP D IV G START
        I '$D(^SYS(0,"PATCH",ANS,"0")) W !!,?5,"Patch #",ANS," not defined, try again!",! G START
        S PATNO=ANS,PTR=0 D LIST
OPT     R !!,"Edit > ",ANS I ANS=""!(ANS="^") G START
        I ANS["?" D HLP9^PATFL5 G OPT
        I ANS?1A&("RDIS"[ANS) D EDIT G OPT
        I ANS?1"L"1" ".N!(ANS="L") D PTR G OPT
        D IV G OPT
PTR     I ANS="L" D LIST Q
        S LINE=$P(ANS," ",2) I LINE="" D LIST Q
        I '$D(^SYS(0,"PATCH",PATNO,LINE)) W !,?7,"Line #",LINE," not defined, try again!" Q
        S PTR=LINE
LIST    S GL="^SYS(0,""PATCH"","""_PATNO_""","""_PTR_""")"
        I 'PTR W !!,GL,?28,"Date: ",$P(@GL,"/",2),!,?28,"Title: ",$P(@GL,"/",3) Q
        W !!,?31,"Module",?42,"Address",?56,"Old",?69,"New",!,?42,"Offset",?54,"Contents",?67,"Contents"
        S JDB=$P(@GL,"/",4) W !,GL,?31,$P(@GL,"/",1),?37,$J($P(@GL,"/",2),11),$J($P(@GL,"/",3),13) W:JDB'["+" $J(JDB,13) W:JDB["+" ?
68,JDB
        Q
EDIT    G:ANS="R" REDI^PATFL5 F I=1:1 I $E("DIS",I)=ANS G @("EDIT"_I)
EDIT1   I PTR=0 W "   First line can not be deleted" Q
        K ^SYS(0,"PATCH",PATNO,PTR) I $N(^SYS(0,"PATCH",PATNO,PTR))=-1 S PTR=PTR-1 Q
        S TEMP=PTR
SUBS    S NEXTL=$N(^SYS(0,"PATCH",PATNO,TEMP)) I NEXTL=-1 K ^SYS(0,"PATCH",PATNO,TEMP) Q
        S ^SYS(0,"PATCH",PATNO,TEMP)=^SYS(0,"PATCH",PATNO,NEXTL)
        S TEMP=NEXTL G SUBS
EDIT2   R !!,?7,"Module name ? > ",ANS Q:ANS=""!(ANS="^")
        I ANS["?" W !!,"Enter one of the following:" S ANS=""
        S SS="",TAB=$P($T(TAB),";;",2) F I=1:1 S MODUL=$P(TAB,"/",I) Q:MODUL=""  I $E(MODUL,1,$L(ANS))=ANS W:(SS'="S"&(SS'="")) !?3,
SS S SS=$S(SS="":MODUL,1:"S") W:SS="S" !?3,MODUL
        D:SS="" IV I SS=""!(SS="S") G EDIT2
        W $E(SS,$L(ANS)+1,99)
ADOFF   R !,?7,"Address offset ? > ",ADOFF G:ADOFF=""!(ADOFF="^") EDIT2
        I ADOFF["?" D HLP5^PATFL5 G ADOFF
        I ADOFF'?.N!(ADOFF[8)!(ADOFF[9)!(ADOFF#2) D IV G ADOFF
OLDCO   R !,?7,"Old contents ? > ",OLDCO G:OLDCO=""!(OLDCO="^") ADOFF
        I OLDCO["?" D HLP6^PATFL5 G OLDCO
        I OLDCO'?.N!(OLDCO[8)!(OLDCO[9)&(OLDCO'?1"X"."X") D IV G OLDCO
NEWCO   K DIR R !,?7,"New contents ? > ",NEWCO G:NEWCO=""!(NEWCO="^") OLDCO
        I NEWCO["?" D HLP7^PATFL5 G NEWCO
        I NEWCO["+" S ANS=NEWCO D MDBAS^PATFL1 G:$D(DIR) NEWCO G SET
        I NEWCO'?.N!(NEWCO[8)!(NEWCO[9) D IV G NEWCO
SET     S LINE=PTR F I=1:1 S NEXTL=$N(^SYS(0,"PATCH",PATNO,LINE)) Q:NEXTL=-1  S LINE=NEXTL
        G:I=1 INSRT F I=1:1 S ^SYS(0,"PATCH",PATNO,LINE+1)=^SYS(0,"PATCH",PATNO,LINE),LINE=LINE-1 Q:LINE=PTR
INSRT   S ^SYS(0,"PATCH",PATNO,LINE+1)=SS_"/"_ADOFF_"/"_OLDCO_"/"_NEWCO,PTR=PTR+1 Q
EDIT3   S PTR=PTR+1 I '$D(^SYS(0,"PATCH",PATNO,PTR)) W !,?7,"Line #",PTR," not defined" S PTR=PTR-1 Q
        D LIST Q
IV      W !!,?7,"Incorrect response, enter ""?"" for help",! Q
END     K ADOFF,ANS,GL,I,LINE,MODUL,NEWCO,NEXTL,OLDCO,PATNO,PTR,SS,TAB,TEMP,JDB
        S %NOPAUSE=1 Q
TAB     ;;VECTOR/SYSTAB/EXEC/MUMPS/PATCH/INTERP/SUBRS/EVAL/SYMBOL/GLOBAL/ALLOC/ZCALL/KEXEC/DISK/EMT/KIOD/KSPOOL/DSMXDT/MTD/EBCDIC/JR
NL/SDP/DMC/JOBCOM/DDP/USRDRV/DDBTAB/CONFIG/BOOTDK/TU58/RX02/BISYNC
