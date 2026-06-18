%SY     ;System status : JEC ; 21-Nov-80  1:33 AM
        S %SF=0
        S %DT=+$H D %CDS^%H S DATE=%DAT1
        W $ZV,"  System Status at " D TIME W "  " D GETJBS G START
REMOTE  S %SF=0,%DT=+$H D %CDS^%H S DATE=%DAT1
        W !,"System Status on NODE: ",NODE," at " D TIME W "  "
START   W %ACT," jobs active",!
        W !,"Job",?4,"State",?12,"Devices",?22,"Uci",?30,"Routine",?41,"Job",?45,"State",?53,"Devices",?63,"Uci",?71,"Routine"
        W !,"---",?4,"-----",?12,"-------",?22,"---",?30,"-------",?41,"---",?45,"-----",?53,"-------",?63,"---",?71,"-------",!
        S OFT=0,I="" F %I=1:1 S I=$O(JT(I)) Q:I=""  D  S OFT='OFT
        .S K=$P(JT(I),"^") S:K#128=1 K=$V(248,I)#256+100+(K["T"*500)
        .S J=$P($T(@+K)," ",2,3) S:J="" J=$P($T(@(K-128))," ",2,3)
        .W ?OFT*41+0,I
        .W ?OFT*41+4,J
        .W:$D(JD(I)) ?OFT*41+12,$E(JD(I),1,$L(JD(I))-1)
        .W ?OFT*41+22 W $P(JT(I),"^",2)
        .W ?OFT*41+30 W $P(JT(I),"^",3)
        .I I=126 W "Journal"
        .I I=127 W "Gar Col"
        .I OFT*41=41 W !
        K JT,JD,%ACT,%DAT,%DAT1,%DT,%I,%SF,A,DATE,DT,I,J,JM,OFT
EXIT    Q
TIME    S %M=$P($H,",",2)\60,%N=" am" S:%M'<720 %M=%M-720,%N=" pm"
        S:%M<60 %M=%M+720 S %I=%M\600 S:'%I %I=" "
        W DATE,"  ",%I,(%M\60#10),":",(%M#60\10),(%M#10),%N
        K %M,%N,%I Q
ERR     I $ZE'["INRPT" W !!,"ERROR IN STATUS MONITOR ",$ZE
        W !!,"END STATUS MONITOR",! S $ZT="" Q
ZJ      S $ZT="ZJERR^%SY" ZA ^%Q("STATUS","%SY") S ^%Q("STATUS","%SY")="STARTED"
        ZA ^%Q("STATUS","REQUEST"):0 I  G ZJERR
        K ^%Q("STATUS","JOB"),^%Q("STATUS","DEVICE")
        D GETJBS S ^%Q("STATUS","JOB")=%ACT
        S J="" F I=1:1 S J=$O(JT(J)) Q:J=""  S ^%Q("STATUS","JOB",J)=JT(J)
        S J="" F I=1:1 S J=$O(JD(J)) Q:J=""  S ^%Q("STATUS","DEVICE",J)=JD(J)
        S ^%Q("STATUS","%SY")=^%Q("STATUS","%SY")_",COMPLETE"
ZJERR   ZD  Q
GETJBS  K JT,JD S ST=$V(44),JT=$V(ST+4),DT=$V(ST+8),JM=$V($V(ST+6))\512
        F I=JT+2:2:JT+126 I $V(I+1),$V(I+1)'=244 S J=I-JT\2 D SETRU S JT(J)=$V(I+1)_"^"_A_"^"_N
        F I=JT-128:2:JT-128+(2*(JM-63)) I $V(I+1),$V(I+1)'=244 S J=I-(JT-128)/2+64 D SETRU S JT(J)=$V(I+1)_"^"_A_"^"_N
        F I=-14:0 S I=$V(JT+I)#256 Q:'I  S $P(JT(I\2),"^")=$P(JT(I\2),"^")_"T" S:I>127 I=I-256
        S:$V(ST+410) JT(126)="999^@@@,@@@" S:$V(ST+364) JT(127)="999^@@@,@@@"
        S J=$J D SETRU S JT($J)="999^"_A_"^"_N
        S %ACT=$V(ST+350)+$D(JT(126))+$D(JT(127))
        F I=DT+1:1:DT+255 S J=$V(I)#256\2 I J>0&(J<127) S:'$D(JD(J)) JD(J)="" S JD(J)=JD(J)_(I-DT)_","
        Q
SETRU   S N="" F A=126:1:133 Q:$V(A,J)#256>127!'$V(A,J)  S N=N_$C($V(A,J)#128)
        S A=$V(149,J),$ZT="NOUCI",A=$ZU(A#32,A\32) Q
NOUCI   S A="@@@,@@@" Q
        S A=$V(149,I) D GETUCI Q
999     running
226     ddpbufq
228     ddpsrvq
230     shortq
232     iordyq
234     wait1q
236     wait2q
238     wait3q
240     wait4q
242     clockq
244     availq
246     glbaccq
248     glblckq
250     jrnlq
138     globufq
1       trm hng
2       jrn hng
3       dsk hng
4       mt hng
5       usrdrv
6       dmc hng
7       jcm hng
8       DDP hng
9       BSChang
11      dskinhb
12      lockcmd
13      hangcmd
14      bufall
15      SPLwait
16      SDPwait
17      logout
18      opencmd
19      protect
20      SPLdir
100     Pgmr Rd
142     Read *
180     P cmd
182     TT read
187     TT Wrt
304     Zload
508     ZPrint
515     ZWrite
642     Tim Rd*
682     Tim Rd
