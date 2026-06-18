MAKESDP ;TEMP ROUTINE TO SAVE ROU'S IN SDP SPACE
        S INSMAPS=4,ST=$V(44)
        S SYDDU=$P("DK,DM,DR,DB,DL,DU",",",$V(ST+56)\32+1)_($V(ST+56)\4#8)
        C 59 O 59::1 E  W !,"Waiting for device 59..." O 59 W "got it.",!
        S ST=$V(44),STR=$V(ST+12),STR1=$V(ST+34)#256+STR
        I '$V(STR1+2) W !,"MAKESDP requires the MOUNTABLE VOLUME sets system option",!,"RUN SYSGEN to include it",! Q
        I $V(STR1) W !,"A volume set is already mounted as S1",!,"You must first dismount it before running MAKESDP",! Q
        K ^PATCH S ^PATCH=""
        I '$D(^SYS(0,"PATCH")) G ZT
        S QUES="PATQ" X ^%Q("ASKN") I %A C 59 Q
        I ANS'="Y" G ZT
        S G="^SYS(0,""PATCH"")" F I=1:1 S G=$ZO(@G) Q:G'["PATCH"  S @("^PATCH("_$P(G,"(",2))=@G
ZT      S QUES="HOST" X ^%Q("ASKN") I %A C 59 Q
        I ANS="Y" G ONSYS
        C 63 O 63::1 E  W !,"Waiting for device 63..." O 63 W "got it.",!
        S PRM="Create a distribution disk",M=0,MAPS=0 D GETYU^DPBEGIN I '$D(%A) Q
        I %A=1 Q
        S SHOW=1,%UPG=0
        D START^DPFORMAT I %FMT D START^DPFMT30 I %A G MAKESDP
        I %TST D START^DPTEST I %A G MAKESDP
        D START^DPLABGET,START^DPBBSET,START^BBTAB,START^LABEL
        S VOLNAM="INS",CODE=$P($H,",",2)#65536,UCB=92,UNIT=1,MB="M",%SIZ=%MP D START^DPNEWL
        D SYCHK^DPINIT,START^DPINIT,INITSY^DPINIT
        S SAT=$V(STR+4)
        V STR1::19366
        V STR1+4::SAT,0:SAT:%MP,2:SAT:65535
        V STR1+6::0
        V STR1+8::%MP
        V STR1+10::%TY*8+$E(DDU,3)*4
        V UCB:DDU S UCT=$V(STR1+2) F I=0:2:18 V I:UCT:$V(I,0)
        S X=$V(ST+310)#2 V ST+310::$V(ST+310)-X
        X "ZL STUDIST V 148:$J:$V(148,$J)#256+(33*256) ZS STU V 148:$J:$V(148,$J)#256+256"
        V ST+310::$V(ST+310)+X
        V STR1::0
        S %TYPE=$P(%D," ",2) D COPYDK^DPSYCOPY
        S MAPS=INSMAPS,OFF=0,MAP=%MP-MAPS I MAP<1 S MAPS=MAPS+MAP,MAP=0,OFF=210
        C 63 O 63
        F I=0:2:1022 V I:0:0
        V 1008:0:43690,1010:0:65535-43690
        F I=MAP:1:MAP+MAPS-1 V -(I*400+399):DDU
        S VT=$V(ST+138) V 60:VT:%TY*8+$E(DDU,3)*1024+MAPS,62:VT:MAP
        S VOL=1 G SDP
ONSYS   S DDU=SYDDU
        S %MP=$V($V(ST+56)#256+$V(ST+224)+2)
        S OFF=0,MAP=%MP-INSMAPS I MAP<INSMAPS W !,"Not enough space on system disk" G MAKESDP
        S MAPS=INSMAPS
SDP     S U=59 U 59:(0:MAP*400+OFF:DDU) I $ZA<0 U 0 W !,"SDP map ",MAP," not available." G MAKESDP
        S LAST=MAP+MAPS*400-10
        K (VOL,U,DDU,LAST,MAP,MAPS)
        S SDP=1 D ROUGLO^V3UTILS
        U 0 W !,"Done creating distribution kit",!
        U 59 S BLK=$ZA,BYTE=$ZB
        U 0 W "Next available SDP byte is at block ",BLK," byte ",BYTE,!
        C 59,63 Q
MOUNT   U 59 W "*TM*",!,"END OF VOLUME ",VOL,! C 59
M1      U 0 S QUES="NEXT" X ^%Q("ASKN") I ANS'="Y" G M1
        U 63:(::"Z"),0 V -16777216:DDU U 63:(::"C"),0
        F I=1:1:MAPS V -(I+MAP*400-1):DDU
        S VOL=VOL+1 O 59:(0:1:DDU) U 59 W "START OF VOLUME ",VOL,!
        Q
NEXT    W !!,"Volume ",VOL," is full. A new diskette is needed in ",DDU,"."
        W !,"Is the new diskette mounted in ",DDU Q
NEXTH   W !,"So mount it!" Q
HOST    W !,"Make SDP on the system disk ? (Type '?' for help) " Q
HOSTH   W !,"This routine can create either a pseudo-distribution disk on the current"
        W !,"system disk (YES), or a real distribution disk on another disk drive (NO)."
        W !!,"If you answer 'YES', you must have already reserved the LAST 3 maps"
        W !,"on the system disk as SDP space. When this routine has finished,"
        W !,"the system disk can be used as a distribution disk by 'D ^STUDIST'"
        W !,"from BASELINE mode only. Notice that if you then tell STUDIST to copy the"
        W !,"distribution disk, it will actually make a true distribution disk."
        W !!,"If you answer 'NO', a real distribution disk will be created. You will"
        W !,"be asked for the name of the drive on which you wish to create a 'real'"
        W !,"distribution disk. If you specify a disk with fewer than 4 maps (like"
        W !,"an RX50) you will be told when to mount a new diskette, so stick"
        W !,"around until it's done. For creating a real distribution disk, your"
        W !,"system must be started up, have structure S1 available, and have no"
        W !,"other volume sets mounted.",!
PATQ    W !,"Create ^PATCH" Q
PATQH   W !,"Do you wish to copy patches from ^SYS(0,""PATCH"") to another"
        W !,"global called ^PATCH ?  This global will then be copied to"
        W !,"the distribution, and be restored to ^SYS(0,""PATCH"") by the"
        W !,"installation procedure.",! Q
