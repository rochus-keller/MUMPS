REST    ;DSM11 UTILITIES; COPYRIGHT 1980 DEC
START   K  U 0 C 47,48,49,50,63 S UU=-1
        ;I $I'=1 W !,"THIS IS NOT THE SYSTEM CONSOLE",! G DONE
        O 63:2:3 E  W !,"VIEW BUFFER BUSY",! G DONE
        S $ZT="CLOSE^REST"
        S ST=$V(44),H=256,UU=-1,Q=""""
        D TYPES^SYSROU
        S SYU=$P(TYPES,",",$V(ST+56)#256\32+1)_($V(ST+56)#32\4)
        S ID="" S:$V(ST+35)#2=0 ID=^SYS(0,"RUNNING")
RESTART ;
ADQ     S QUES="DQ",DEF="" X ^%Q("ASK") G DONE:ANS=""!%A I ANS'?2A1N D IV G ADQ
        S MD=$E(ANS,1,2),MU=$E(ANS,3),MTYP=$F(TYPES,MD)\3-1
        S MDE=MTYP*8+MU*4+$V(ST+224)
        I MTYP<0 D THLP G ADQ
        S MB=0,RESY=(ANS=SYU) G MLAA:ID=""
        S DD=MD,DU=MU,DE=MDE D DRVCHK^RESTRTNS G DONE:%FAIL<0,ADQ:%FAIL
MLAA    S LQ=0
MLA     S QUES="LQ" X ^%Q("ASK") G ADQ:ANS=""!%A S ML=ANS
        I ML'?1"""".E1""""!($L(ML)<3)!($L(ML)>24) D LQH G MLA
DORM    S %A=0,ANS="D",ZT=$ZT,$ZT="DORM0" O 47 S %A=1 C 47
DORM0   S $ZT=ZT G:'%A DORM1
        S QUES="DMQ",DEF="D" X ^%Q("ASK") S DEF="" G ADQ:%A S ANS=$E(ANS,1)
        I "MD"'[ANS D IV G DORM
DORM1   S MAG=ANS="M" G MAGRE:MAG
DSKRE   S QUES="FRMQ" X ^%Q("ASK") G MLAA:ANS=""!%A I ANS'?2A1N D IV G DSKRE
        I MD_MU=ANS W !,"Both disk units cannot be the same!",! G ADQ
        S XD=$E(ANS,1,2),XU=$E(ANS,3),XTYP=$F(TYPES,XD)\3-1
        I XTYP<0 D THLP G DSKRE
        S XB=0,XDE=XTYP*8+XU*4+$V(ST+224)
        I ID="" S:ANS=SYU RESY=-1 G NEXTP
        S DD=XD,DU=XU,DE=XDE D DRVCHK^RESTRTNS G DONE:%FAIL<0,DSKRE:%FAIL
        G NEXTP
MAGRE   D MAGASK^RESTMAGU G DONE:%FAIL,DORM:%A,NEXTP
NEXTP   G RSETUP^RESTMNT
CLOSE   U 0 W !!,$ZE,!
DONE    U 0
        C:UU>0 UU C 63 Q
IV      W !,"Incorrect response - enter '?' for more information",! Q
THLP    W !,"VALID DISK TYPES ARE:",!
        F VT=1:1 Q:$P(TYPES,",",VT)=""  W ?4,$P(TYPES,",",VT)
        W ! Q
DQ      W !,"Which drive will contain the disk to be restored *to* " Q
DQH     W !,"Enter the 3-character designation, for example:  DM1",!
        W "of the drive that will hold the disk you wish to re-create",!
        W "from its backup.",! Q
DMQ     W !,"Will you be restoring this disk from another disk, or from "
        W !,"magtape  [ D or M ] " Q
DMQH    W !,"Enter 'D' if the backup to be restored *FROM* is disk, 'M' if "
        W "magtape.",! Q
FRMQ    W !,"Which drive will contain the backup disk being restored from" Q
FRMQH   W !,"Enter the 3-character designation, for example:  DR1"
        Q
LQ      W !,"What will this disk's Master Label be" Q
LQH     G LQH2:LQ S LQ=1
        W !,"Enter the label, up to 22 characters, enclosed in quotes, like "
        W "this:",!,?5,"""THE LABEL""",!!
        W "Enter '?' for further help.",! Q
LQH2    W !,"In order to perform the RESTORE, the disk being restored to must "
        W "first have",!
        W "the correct Master Label.  If it already does, just enter that "
        W "label enclosed",!
        W "in quotes.  If it doesn't, you may put a label on it by typing:  "
        W " D ^LABEL",!!
        W !,"If you do not remember what the Master Label should be, you "
        W "may find",!
        W "out also by typing:   D ^LABEL",!
        W "and examining the label of the Backup volume.",!!
        S LQ=0 Q
