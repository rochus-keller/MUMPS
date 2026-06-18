STUDIST ; DSM-11 Utilities/Copyright 1980 DEC ; Start up system installation from disk distribution
START   K  U 0:(::::16384) S ST=$V(44),DT=$V(ST+224),VTBL=$V(ST+138),DDB=256 B 2 S $ZT="NOSTK" ZT
NOSTK   B -2 O 63::1 E  W "Waiting for VIEW device 63..." O 63 W "got it.",!
        S MAPS=4
        S SYTYU=$V(ST+56)#256\4
        S SYDDU=$P("DK,DM,DR,DB,DL,DU",",",SYTYU\8+1)_(SYTYU#8)
        S OFF=0
        S MAP=$V(SYTYU*4+$V(ST+224)+2)-MAPS
        I MAP<1 S MAPS=MAPS+MAP,MAP=0,OFF=210
        F I=1:1:MAPS V MAP+I*400-1:SYDDU I $V(1008,0)'=43690 W !,"Invalid distribution disk!" G STOP
        V 60:VTBL:SYTYU*1024+MAPS,62:VTBL:MAP
        I $V(ST+35)#2=0 G OPEN
        V ST+408::DDB
        F I=0:2:$V(ST+232)-2 V DDB+I::0
        V $V(ST+8)+58::255
OPEN    O 59::1 E  W "Waiting for SDP device 59..." O 59 W "got it.",!
        S %LABEL="DISKENT",%LOAD="U 59 ZL  S Z=$ZA U 0 ZT:Z>-1  W ""ZLOAD error!"" W $ZE F I=1:1"
        I MAPS<4 G GOPREP
        W !,"  This is a  ",$ZV,"  Distribution Disk.",!
        W !,"You can use this specialized DSM-11 system either to create your own",!
        W "DSM-11 system, or to copy this disk onto another disk (as a backup).",!!
CPASK   S QUES="COPQ" D ASKYN G:%A CPASK I ANS="N" G GOPREP
        S PRM="Make copy",M=0 D SDPINI X "ZL  ZL  U 0 G GETYU"
        I '$D(%A) G CPASK
        S %LABEL="COPENT"
        D SDPINI X "ZL  ZL  U 0 G NXTP"
        Q
GOPREP  D SDPINI K (%LOAD,%LABEL,SYDDU,SYTYU)
        X "S $ZT=%LABEL "_%LOAD
        Q
SDPINI  U 59:(0:MAP*400+OFF:SYDDU)
STOP    Q
COPQ    W !,"Do you wish to make a copy" Q
COPQH   W !,"Answer 'Y' only if you wish to create another Distribution Disk, "
        W "for",!,"example "
        W "to keep as a backup copy.  You should create AT LEAST ONE backup",!
        W "copy "
        W "immediately upon receiving your Distribution Disk."
        W !,"The copying procedure will take a few minutes (the exact time will"
        W !,"depend on the type of disk you are copying to).",!!
        W "Answer 'N' to proceed with normal disk preparation -- preparation of "
        W "the",!
        W "disk you will use in your ",$ZV," system.",!!
        Q
ASK     S %QMK=" ?",%YN="" G A1
ASKYN   S %QMK=" ?",%YN=" [Y OR N]",DEF=""
A1      D @QUES W %YN,%QMK,"   " W:DEF'="" "<",DEF W ">  "
        R ANS,! I ANS="?" D:$L($T(@(QUES_"H"))) @(QUES_"H") G A1
        S %A=ANS="^" Q:%A  S:ANS="" ANS=DEF Q:%YN=""  S ANS=$E(ANS,1)
        Q:"YN"[ANS  G A1
COPENT  ZS STU
        C 63 O 63:BF
        F I=0:BF:MAPS*400-BF V MAP*400+I:SYDDU,-(%MP-MAPS*400+I):DDU
        U 63:(1:1) F I=I+BF:1:MAPS*400-1 V MAP*400+I:SYDDU,-(%MP-MAPS*400+I):DDU
        C 59,63 U 0 W "  ** End of copy",!!
        W "Boot either disk to make further copies, or to proceed with"
        W !,$ZV," system installation.",!!,"Exit",!! B 0
H       H 1 G H
