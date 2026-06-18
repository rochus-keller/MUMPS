PATFL2  ;YZH;23-JUN-80;DELETE PATCHES FROM ^SYS(0,"PATCH") GLOBAL
        W !,*7,"This subroutine should be run using the autopatch utility ^AUPAT.",!,*7 Q
START   R !!,"Delete patch number ? > ",ANS I ANS=""!(ANS="^") G END
        I ANS["?" D HLP1 G START
        I ANS'?1N.ANP D IV G START
        S PATNO=ANS
        I '$D(^SYS(0,"PATCH",PATNO,"0")) W !!,"Patch #",PATNO," has not been filed, try again!",! G START
        S GL="^SYS(0,""PATCH"","""_PATNO_""",""0"")"
        W !!,?2,"Patch #",PATNO,?14,"Date: ",$P(@GL,"/",2),!,?14,"Title: ",$P(@GL,"/",3)
CHK     R !!,"Are you sure ? <N> ",ANS I ANS=""!(ANS="^") G START
        I ANS["?" D HLP2 G CHK
        I $E("NO",1,$L(ANS))=ANS G START
        I $E("YES",1,$L(ANS))=ANS G DEL
        D IV G CHK
DEL     K ^SYS(0,"PATCH",PATNO) W !!,"Patch #",PATNO," deleted",! G START
IV      W !!,"Incorrect response, enter ""?"" for help",! Q
END     K ANS,GL,PATNO
        S %NOPAUSE=1 Q
HLP1    W !!!,"Enter the patch number you want to delete from ^SYS(0,""PATCH"") global",! Q
HLP2    W !!!,"Enter Y(ES) if you want patch #",PATNO," to be deleted"
        W !,"Enter N(O)  if you do not want patch #",PATNO," to be deleted",! Q
