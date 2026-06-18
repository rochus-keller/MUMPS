SYCOPY  ;
        U 0 C 63 O 63::3 G START:$T W !!,"View buffer is busy -- please "
        W "try again later.",!!
        Q
START   K  W !,"...Copy a new system-image onto a disk...",!!
ST2     S $ZT="OPN47" O 47::0 C 47 S $ZT="" G ASKFR
OPN47   S $ZT="" I $ZE'["NODEV" W !,$ZE G EXIT
FRDSK   S PRM="Copy system-image FROM disk volume" D GETU G EXIT:%A
        S SYDDU=DDU G TODSK
ASKFR   S DEF="",QUES="FRQ" X ^%Q("ASK") S ANS=$E(ANS,1) G:ANS=""!%A EXIT
        G:ANS="D" FRDSK I ANS'="T" D FRQH G ASKFR
TPASK   R !,"Copy from which magtape unit (0, 1, 2, or 3) ?  > ",Y,!
        G EXIT:Y=""!(Y="^"),CPHLP:Y="?" I Y'?1N!(Y>3) G TPASK
        S %UNIT=47+Y,ST=$V(44)
DQGET   S OP="BT3",DEF="800",QUES="DQ" X ^%Q("ASK") G EXIT:%A,DENOK:ANS=800
        I ANS'=1600 D DQH G DQGET
        S OP="BT4"
DENOK   S DEF="",QUES="BOIM" X ^%Q("ASKYN") G DQGET:ANS=""!%A
        S SPC=(ANS="N")*4
TODSK   S PRM="Copy system-image TO disk volume" D GETU G ST2:%A
        K WFIX,UNBRK,FORMAT,%AGAIN,%BMAX
        K DEF,%A,%QUES,%YN,%QUES,ANS
        W !!,DDU," is "
        I %LB="" W "not a DSM-11 disk volume" G ABS
        W "is a ",$E(VER,1,8)," ",$S(MB="M":"Master",1:"Backup")," disk volume"
        W !,"With label: ",%LB
        I %TY*8+$E(DDU,3)*4=($V($V(44)+56)#256) W !,"Which is in fact your present system disk.",!
ABS     W !!,"Are you absolutely sure"
        W !,"you want to copy the system-image onto this disk"
        D ASKYN G COPY:Y,EXIT
COPY    I $D(SYDDU) D COPYDK^DPSYCOPY G COPDON
        D COPYMT^DPSYCOPY
COPDON  U 0 W !,"System-image copy complete",!
%ERRET  ;
EXIT    I $D(%UNIT) C %UNIT
        C 63 K  Q
ASKYN   R " ? [Y/N]  > ",Y,! I "YN"[$E(Y,1)&$L(Y) S Y=$E(Y,1)="Y" Q
        W " Yes or No" G ASKYN
CPHLP   W !,"This program is used to copy a new ",$ZV," system image from"
        W " a",!
        W "distribution magtape or disk to blocks 0 thru 91 of a ",$ZV," system disk.",!
        W !,"It should not be used to copy a V3 image to a *V2* system disk"
        W " that has",!,"not been upgraded.",!
        W !,"If you wish to terminate execution of this program now, just "
        W "hit  <CR>.",!! G TPASK
DQ      W "Density [ 800 or 1600 ] " Q
DQH     W !,"If the tape was created on a TS11/TS05 drive, it will be 1600 bpi."
        W !,"If it was created on a TM11/TS03 or TU10 or TE10, it will be "
        W "800 bpi.",!
        W "Otherwise, you may have to try both densities.",!! Q
FRQ     W !,"Copy  * from *  Tape  or  Disk [ T or D ] " Q
FRQH    W !,"Is the system image you want to copy, currently on a tape or "
        W "on a disk?",! Q
BOIM    W !,"Either the tape is bootable or it is a task-image tape.",!
        W "Is it bootable" Q
BOIMH   Q
GETU    S %A=1 O 63::2 E  W !,"View buffer is busy, unable to proceed." Q
        S M=1,MAPS=0 K %QUERY
        D GETYU^DPBEGIN I '$D(%A) S %A=1 Q
        S %TYPE=$P(%D," ",2),%A=0 Q
