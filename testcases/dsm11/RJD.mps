RJD     ;DSM11 UTILITIES;COPYRIGHT 1980 DEC;RESTORE JOB/DEVICE
        S ST=$V(44),DEVT=$V(ST+8)
RESTORE S QUES="RES",DEF="" D ASK Q:ANS=""!%A
        S JD=$E(ANS,1),ANS=$E(ANS,2,99) I "JD"'[JD!(ANS'?1N.N) D IV G RESTORE
        G RESJ:JD="J"
RESD    I ANS<1!(ANS>255) D IV G RESTORE
        S DEV=ANS,J2=$V(DEVT+DEV)#256
        I J2=255 W !,"Device ",DEV," not in system.",! G RESTORE
        S J2=J2\2 I J2=0 W !,"Device ",DEV," is not owned." G RESTORE
        I $V(146,J2)=DEV W !,"This is job # ",J2,"'s "
        I  W "principal device.",!,"You must restore the job to free this device." G RESTORE
        I J2=$J W !,"Sorry, that's your own device." G RESTORE
        D OPEN1 S VAL=$J*2 D TAKE
        I $V(216,J2)=DEV V 216:J2:$V(146,J2)
        C DEV D CLOSE W " restored." G RESTORE
RESJ    I ANS<1!(ANS>110) D IV G RESTORE
        S JOB=ANS I JOB=$J W !,"You can't restore your own job !!",! G RESTORE
        D OPEN1 D SHUTJ,CLOSE W " restored." G RESTORE
SHUTJ   Q:JOB=$J  S ST=$V(44),J2=JOB*2
        I $V(2,JOB)'="" V 2:JOB:$V(2,JOB)#4096+16384,ST+74::J2
        Q
TAKE    S DT=DEVT+DEV I DT#2 V DT-1::$V(DT-1)#256+(VAL*256) Q
        V DT::$V(DT+1)*256+VAL Q
TRAP    S $ZE="TRAP1" V ST::0
TRAP1   C:U U S $ZE="" B 1
DONE    K  Q
OPEN1   B 0 Q
CLOSE   S $ZE="" B 1 U 0 Q
IV      W !,"Incorrect response - enter '?' for more information",! Q
RES     W !,"Restore" Q
RESH    W !,"Enter Job Number preceded by 'J', or Device Number preceded "
        W "by 'D'.",!
        W "Valid Job Numbers are 1-63, valid Device Numbers are 1-255.",! Q
EN      S QMK="",%YN="" G SAYQ
ASKY    S DEF="Y" G ASKYN
ASKN    S DEF="N"
ASKYN   S QMK=" ?",%YN=" [Y OR N]" G SAYQ
ASK     S QMK=" ?",%YN=""
SAYQ    D @QUES W %YN,QMK,"  " W:DEF'="" "<",DEF W ">   " R ANS,!
        I ANS="?" D:$L($T(@(QUES_"H"))) @(QUES_"H") G SAYQ
        S %A=0 S:ANS="^" %A=1 S:ANS="" ANS=DEF Q:%YN=""
        S ANS=$E(ANS,1) Q:"YN^"[ANS  D VALID^SYSROU G SAYQ
