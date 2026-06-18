MOUNT   ;DSM11 UTILITIES; COPYRIGHT 1980 DEC
        G OK:$V($V(44)+35)#2=0
        W !,"Cannot mount/dismount disks in baseline mode.  (You may access"
        W " any disk",!
        W "using the ""VIEW"" command, however.)",! G EXIT
        D CHKSYS^SYSROU G EXIT:%A
OK      C 63 O 63::1 E  W !,"View buffer busy",! G EXIT
        K  S ST=$V(44) S (M,MAPS)=0,PRM="Mount a volume" D GETYU^DPBEGIN I '$D(%A) Q
        I %A=1 Q
        I %A!(VER'["DSM11") G NOTDSM
        S A=394,L=4 D GET S VOLNAM=$E(S,1,3),VOL=$E(S,4),VOLS=$V(512+401,0)
        W !,DDU," has a ",$E(VER,1,10)," ",$S(MB="M":"MASTER",MB="B":"BACKUP",1:"")," label: """,%LB,""""
        I VER'["V3"!(MB'="M"&'$V(815,0)) G NOTSTR
        I VOLNAM'?3U G NOTUCI
        W !,DDU," is volume ",VOL," of volume set ",VOLNAM," which has ",VOLS," disk"
        W:VOLS>1 "s" W ".",!
        I VOL>1 G SDP
        I VOLS=1 G DB
        W !,"Volume set ",VOLNAM," consists of the following ",VOLS," disks:"
        F I=1:1:VOLS S %D=$V(I-1*4+512+402,0)#256 D
        .D %D^DPBEGIN W !,"Volume ",I," is an ",$P(%D," ",2)
DB      W !,"Mount ",DDU," for access via: [S]DP, [V]IEW, or [D]ATABASE "
        R "? ",Y I Y=""!(Y="^") G NOMNT
        I Y="?" D DBHELP G DB
        I Y="S" S STR=-1 G DOIT
        I Y="V" G VWMNT
        I Y'="D" D NVALID G DB
        D START^%STRTAB
        S STR="" F I=1:1 S STR=$O(STR(STR)) Q:STR=""  I STR(STR)="" Q
        I STR="" W !,"Sorry, the Volume Set table is full." G NOTSTR1
NEW     W !,"What name do you wish to use for this volume set <",VOLNAM,"> ? "
        R A I A="^" Q
        I A="" S A=VOLNAM
        I A'?.3U W !,?5,"Please enter 3 uppercase characters" D SHOW^%STRTAB G NEW
        S STNAM=A
NAMCHK  S N="" F I=1:1 S N=$O(STR(N)) Q:N=""  I STR(N)=STNAM D  G:A="^" MOUNT G NAMCHK
        .W !,"Mounted volume set ",N," is already named """,STNAM,"""" S A="^"
        S STAB=$V(ST+12),SAT=$V(STAB+4)
        F I=0:1:3 S MM=$V($V(ST+34)#256*I+STAB+4) I MM>0 S SAT=$V(0,MM)+511\512+SAT
DOIT    S STMAP=0 D START^MAPMOUNT
        I %A G NOMNT
        S SCM="MIS" D ALINKS^DDPSRV G EXIT
NOTUCI  W !,DDU," is a non-UCI mountable volume that cannot be used for globals or routines."
SDP     W !,"Mount ",DDU," for access via: [S]DP or [V]IEW ? " R Y
        I Y="?" D SDPHLP G SDP
        I Y="^"!(Y="") G NOMNT
        I Y="S" S STR=-1 G DOIT
        I Y="V" G VWMNT
        D NVALID G SDP
DBHELP  W !!,"'Database' access means normal MUMPS global and routine access."
        W !,"The volume set becomes one of the 4 mounted volume sets available for"
        W !,"access by either login or extended global syntax, and via DDP."
SDPHLP  W !,"'SDP' means access for SDP, JOURNAL, or SPOOLING."
        W !,"The disk will not be one of the 4 mounted volume sets accessible"
        W !,"for globals and routines, and you can't login to it."
VIEWH   W !,"When a disk is mounted for VIEW ONLY, you cannot use the disk"
        W !,"for globals, routines, SDP, JOURNAL, or SPOOLING. Usually, the"
        W !,"only reason for mounting VIEW ONLY is to initialize the disk"
        W !,"using the ^DISKPREP utility.",! Q
NOTSTR  W !,"This disk can only be mounted for VIEW ONLY.",!
NOTSTR1 S QUES="VIEW" D ASKYN I '$D(Y) G MOUNT
        I 'Y G MOUNT
VWMNT   W !,"Although you are mounting this disk for view only,"
        W !,"the disk does contain a valid DSM11 bad block table."
        S QUES="BADQ" D ASKYN G:'Y VWONLY
        V %DT+2::$V(512+300,0)
        D GETBB F I=0:2:190 V I:BBMM:$V(512+I,0)
        G MNTVW
NOTDSM  W !,DDU," is not a recognizable DSM-11 disk."
        S QUES="VIEW" D ASKYN I 'Y C 63
        E  G VWONLY
NOMNT   W !!,"Mounting of disk ",DDU," aborted." G EXIT
NVALID  W " -- not valid. Type ""?"" for help.",! Q
VWONLY  V %DT+2::0 D GETBB V 0:BBMM:0
MNTVW   V %DT::$V(%DT)#16384+16384 C 63
        W !,DDU," is now mounted for VIEW only."
        W !,"With" W:'$V(%DT+2) "out" W " bad block remapping"
        I $V(0,BBMM)#256 W " (",$V(0,BBMM)#256," bad blocks)"
EXIT    C 63 K STNAM,VOLS,SATMM,MM,DSK,VOL,VOLNAM,%DT,VER Q
GETBB   S BBMM=$V(%DT)\256#64+$V(ST+86) Q
VIEW    W !,"Mount ",DDU," for VIEW ONLY" Q
GET     S S="" F I=1:1:L S S=S_$C($V(512+A+I-1,0)#256)
        Q
ASKYN   W ! D @QUES R " ? [Y/N]  > ",Y,!
        I "YN"[$E(Y,1)&$L(Y) S Y=$E(Y,1)="Y" Q
        D HELP G ASKYN
HELP    S HROU=QUES_"H" D:$L($T(@HROU)) @HROU Q
ASK     D @QUES R " > ",A,! Q:A'="?"  D HELP G ASK
BADQ    W !,"Use automatic remapping of bad-blocks on this disk" Q
BADQH   W !,"If you expect to be able to access the DSM11 database on this disk,"
        W !,"using VIEW, you must load the bad-block table that is stored on the"
        W !,"disk's label block. If you are going to re-initialize this disk,"
        W !,"erasing the database, you should NOT load the bad block table." Q
