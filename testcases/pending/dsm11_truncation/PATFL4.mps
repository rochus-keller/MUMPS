PATFL4  ;YZH;23-JUN-80;LIST PATCHES FROM ^SYS(0,"PATCH") GLOBAL
        W !,*7,"This subroutine should be run using the autopatch utility ^AUPAT.",!,*7 Q
START   S %QTY=2 D ^%IOS
        I '$D(%IOD) G END
        I "SC^LP^TRM"'[%DTY!(%DTY="") D IV G START
        S %SCR=0,%Z="",%NLIN=20
        I %DTY="LP" G PATNO
PAG     R !,"Scroll ? <N> ",ANS I ANS="^" G START:%IOD=$I C %IOD G START
        I ANS["?" D HLP1 G PAG
        I ANS=""!(ANS'?1"Y".E) G PATNO
        S %SCR=1
ASKL    R !,"Lines/Page ? <20> ",ANS G:ANS="^" PAG
        I ANS["?" D HLP2 G ASKL
        I ANS="" S %NLIN=20 G PATNO
        I ANS'?1N.N!(ANS<1) D IV G ASKL
        S %NLIN=ANS
PATNO   S ALL=0,%Z="" U 0 R !!,"List patch number ? > ",ANS I ANS=""!(ANS="^") G:%IOD=$I START C %IOD G START
        I ANS["?" D HLP3 G PATNO
        I ANS="*" S PATNO=-1,ALL=1 U %IOD W:%DTY="LP" # G GET
        I ANS'?1N.ANP D IV G PATNO
        I '$D(^SYS(0,"PATCH",ANS,"0")) W !,?8,"^SYS(0,""PATCH"",""",ANS,""",""0"") not defined." G PATNO
        U %IOD S PATNO=ANS W:%DTY="LP" # G LIST
GET     S PATNO=$N(^SYS(0,"PATCH",PATNO)) G:PATNO=-1 PATNO
LIST    S (SUBS,CHKSUM)=0,GL="^SYS(0,""PATCH"","""_PATNO_""","""_SUBS_""")" D CHECK G:%Z="^" PATNO
        W !!!,?5,"Patch #",PATNO,?28,"Date: ",$P(@GL,"/",2),!,?28,"Title: ",$P(@GL,"/",3,255)
        I $N(^SYS(0,"PATCH",PATNO,SUBS))=-1 G GET:ALL,PATNO
        D HEAD
CONT    S SUBS=$N(^SYS(0,"PATCH",PATNO,SUBS)) I SUBS=-1 S %DO=CHKSUM D ^%DO W !?56,"Check sum = ",%DO,! G GET:ALL,PATNO
        S GL="^SYS(0,""PATCH"","""_PATNO_""","""_SUBS_""")"
        S JDB=$P(@GL,"/",4) W GL,?31,$P(@GL,"/",1),?37,$J($P(@GL,"/",2),11),$J($P(@GL,"/",3),13) W:JDB'["+" $J(JDB,13),! W:JDB["+" ?
68,JDB,!
        S %OD=JDB S:%OD["+" %OD=$P(%OD,"+",2) D ^%OD S CHKSUM=CHKSUM+%OD
        D CHECK G:%Z="^" PATNO G CONT
CHECK   I 'SUBS&(%DTY="LP") Q:$Y+8'>60  W # Q
        I %DTY="LP" Q:$Y'>60  W # D RP Q
        I '%SCR!($Y<%NLIN) Q
        I 'SUBS&($Y+8<%NLIN) Q
        U 0 R !!,"Enter <CR> for next page ",%Z,!! U %IOD W # Q
RP      W !!!!,?5,"Patch #",PATNO,"   (Continued)",!
HEAD    W !!,?31,"Module",?42,"Address",?56,"Old",?69,"New",!,?42,"Offset",?54,"Contents",?67,"Contents",! Q
IV      W !,?5,"Incorrect response - enter ""?"" for help",! Q
END     K %DTY,%NLIN,%SCR,%Z,ALL,ANS,GL,PATNO,SUBS,JDB
        S %NOPAUSE=1 Q
HLP1    W !!,?5,"Enter Y(ES) to specify the # of lines to be displayed per page"
        W !,?8,"Or N(O) if you want display to be continuous",! Q
HLP2    W !,?5,"Enter the number of lines to be displayed per page"
        W !,?5,"---maximum 20 lines per page for video terminals",! Q
HLP3    W !,?5,"Enter the patch number for which you want a listing"
        W !,?5,"Or  *  to list all the patches in ^SYS(0,""PATCH"") global",! Q
