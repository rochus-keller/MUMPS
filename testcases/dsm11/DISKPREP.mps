DISKPREP        ;DSM UTILITIES; COPYRIGHT 1980 DEC
        K  S SDP=0 C 63 O 63::2 I $T G GETU
        W !,"VIEW buffer is busy... try again later.",! K  Q
GETU    S MAPS=0,M=0,PRM="Prepare a disk" D GETYU^DPBEGIN I '$D(%A) G DONE
        I %A=1,$P(%D," ",6)="N" G DONE
        K D,DSK,PRM
        S ST=$V(44)
        W !!,DDU," contains a "
        I %A=1 W "disk that may need formatting." G USAGE
        I VER'["DSM11" W "disk with no DSM-11 label." G USAGE
        W $E(VER,1,10)
        I MB="B" W " Backup disk." D SHLAB G USAGE
        I VER["V3" W " master disk." D SHLAB G ASKS
        I $V(512+200,0)=0 W " master disk that does not have mountable UCI's."
        E  W " mountable disk with UCI's."
        D SHLAB S QUES="UPG" D ASKYN I 'Y G GETU
ASKS    S UPG=0,QUES="SURE" D ASKYN I 'Y G DONE
USAGE   W !!,"Select usage for this disk:",!
        W !,"[B]ackup"
        W !,"[E]xtend a currently mounted volume set"
        W !,"[C]reate volume 1 of a new volume set"
        W !,"[S]DP/SPOOL/JOURNAL mountable disk"
        R !!,"Select one ? > ",ANS,!
        I ANS="^"!(ANS="") G DONE
        I ANS?1U,"BECS"[ANS G @ANS
        W !,"You must select one of the listed uses so that the label can be"
        W !,"appropriately initialized.  If what you really want is a system"
        W !,"disk, you must create that by booting and running your original"
        W !,"DSM-11 distribution disk, diskette, or magnetic tape.",! G USAGE
E       S MB="M" D START^%STRTAB
        S STR=0,S=0 F I=1:1 S S=$O(STR(S)) Q:S=""  I STR(S)'="" S STR=STR_S
        I STR=0 G STR
SHOW    D SHOW^%STRTAB
SHOW1   R !,"Add this disk to which Volume set ? > ",S,!
        I S=""!(S="^") G USAGE
        I S'?3U D  G SHOW1
        .W !,"Enter the name of the Volume Set that you wish to extend."
        .W !,"Use the 3-character name to specify the Volume set.",!
        F I=0:1:3 I STR(I)=S S STR=I G STR
        W !,S," is not a mounted Volume Set" G SHOW1
STR     U 63:(::"Z"),0 V 0:$P(STR(STR,1),":")
        I $V(916,0),$V(916,0)'=$V(812,0) W !,"This volume has logical size of ",$V(916,0)," maps.  It must be extended to the full "
,!,$V(812,0)," map size using ^DISKSIZ before adding a new volume to the volume set.",! G USAGE
        S UNIT=$V(512+401,0)#256+1
        S CODE=$V(512+392,0) S VOLNAM="" F I=0:1:2 S VOLNAM=VOLNAM_$C($V(512+394+I,0)#256)
        G PREP
C       D NAME I VOLNAM="" G GETU
        S MB="M",UNIT=1,UCB=1
        G PREP
S       S MB="M",VOLNAM="" K UNIT,UCB G PREP
B       S MB="B",VOLNAM="",UNIT=0 K UCI
PREP    S SHOW=1,%UPG=0 W !,"Prepare disk unit ",DDU,!
        D START^DPFORMAT I %FMT D START^DPFMT30 I %A G DISKPREP
        I %TST D START^DPTEST I %A G DISKPREP
        I $V(%DT+1)#64=0 V %DT::3*256+($V(%DT)#256)
        D START^DPLABGET,START^DPBBSET,START^BBTAB,START^LABEL,START^DPNEWL,START^DPINIT
        S SYDDU=$P("DK,DM,DR,DB,DL,DU",",",$V(ST+56)\32#8+1)_($V(ST+56)\4#8)
        C 63 O 63:2 S %TYPE=$P(%D," ",2),(BTEN,ANSTART,ANSIZE)=0 D FRANX^DPSYCOPY,WRTBT^DPSYCOPY
        I VOLNAM="" G SAYDON
        I UNIT=1 G SAYDON
        C 63 O 63:(:::"Z") V 0:"S"_STR
        S ADR=512+402
        V ADR-2:0:$V(ADR-2,0)+256
        V $V(ADR-1,0)-1*4+ADR:0:$P(%D," ",4)*256+$P(%D," ")
        V $V(ADR-1,0)-1*4+2+ADR:0:$P(%D," ",5)
        U 63:(::"Z"),0 V -16777216:"S"_STR
        W !,DDU," is now volume ",UNIT," of structure S",STR,", however, you must",!
        I STR W "dismount and remount the structure"
        E  W "shutdown and reboot the system"
        G SAY
SAYDON  U 0 I MB="B" G DONE
        W !,DDU," is now a mountable volume. D ^MOUNT"
SAY     W " to make the volume accessible.",!
DONE    C 63 K  Q
RDY     W "Is ",$P(STR(STR,1),":")," mounted and ready" Q
SHLAB   W !,"With volume label: """,%LB,"""" Q
SURE    W !,"This operation will destroy all information currently on the disk."
        W !,"Are you sure" Q
NAME    W !,"Every Volume set must have a unique 3-character identifier."
N1      W !,"Enter the 3-character name for the Volume set > " R VOLNAM,!
        I VOLNAM=""!(VOLNAM="^") S VOLNAM="" Q
        I VOLNAM?3U S CODE=$P($H,",",2)#65536 Q
        W !!,"The volume set needs a name composed of three uppercase alphabetic"
        W !,"characters.  This name will be used as the volume set name when the"
        W !,"volume set is later mounted as a DSM-11 database.  You should"
        W !,"attempt to make all of your volume set names unique, however, this"
        W !,"is not mandatory, since you can rename them when you mount them.",!
        G N1
UPG     W !!,"You cannot upgrade this Version 2 disk directly to ",$ZV
        W !,"You must first upgrade to Version 3.0, using a Version 3.0 system."
        W !!,"Do you wish to erase and re-use this disk instead " Q
ASKYN   W ! D @QUES R " ? [Y/N]  > ",Y,!
        I "YN"[$E(Y,1)&$L(Y) S Y=$E(Y,1)="Y" Q
        D HELP G ASKYN
HELP    S HROU=QUES_"H" D:$L($T(@HROU)) @HROU Q
ASK     S HROU=QUES_"H" D:$L($T(@HROU)) @HROU Q
