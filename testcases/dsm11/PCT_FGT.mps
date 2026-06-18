%FGT    ;26-Feb-85 ;DSM11 ;Utilities ;Read a Fast Global Copy tape block by block ;RWB
        W !,?15,"FAST GLOBAL TAPE READ",!!
        S %TD="Q"
        S %TDI=0
        O 63:(2:1):0 E  W !,"VIEW BUFFER NOT ACCESSIBLE",! G END
        S %TFLAG="CB" D ^%TDN G:%TD="Q" END
        S $ZT="ERROR^%FGT",SW=1,BNUM=1
        S %FULLWR=1,OP="D"
        S EOT=0,EX=0
        S EM="!!,?10,""****  END OF TAPE  -  LAST BLOCK = "",BNUM-1,""  ***"",!"
        U %TD:(1024:0) W *6
        U 0 W !!
WS      U 0 R !,"FGT> ",ANS
        I ANS["?" S %QM=13 D ^%FGR4 G WS
        S:(OP="N")!("DS"'[OP) OP="D"
        I '((ANS?.N)!(ANS?.N1"/"1A)!(ANS="")!(ANS?1A)) G WSER
        I ANS="" S NUM=1 G WS1
        I ANS?1A S NUM=1,OP=ANS G WS1
        I ANS?.N S NUM=ANS G WS1
        S NUM=$P(ANS,"/",1),OP=$P(ANS,"/",2)
WS1     S:($A(OP)>96)&($A(OP)<123) OP=$C($A(OP)-32)
        G END:OP="Q",WSER:"BDSN"'[OP,FF:OP="N",BF:OP="B"
        S:OP="D" %FULLWR=1
        S:OP="S" %FULLWR=0
        F R=1:1:NUM W !,"BLOCK NUMBER ",BNUM,! D GETBLK G:EX END U 0 D ^%BLKWT
        W !! G WS
END     I %TD'="Q" U %TD W *5
END1    C %TD C 63
        K %FULLWR,SW,BNUM,J,R,ANS,%TD,I,NUM,EOT,EM,EX,EN,%FGCH,%DEN
        K %DEV,%DO,%DOWN,%F,%RIGHT,%TYPE,BIT,CMCNT,CNT,HH,K,L,OP
        K %TDI
        Q
WSER    W ?15,"{NUMBER""/""[B,D,S,N]},{NUMBER},{[B,D,S,N]},{Q}",! G WS
FF      S $ZT="FFERR^%FGT"
        I EOT W @(EM) G END
        F R=1:1:NUM U %TD:(1024:SW*1024) W *6 S SW='SW S BNUM=BNUM+1
        G WS
FFERR   S I=$ZA,J=$ZE U 0
        I (I\16384#2)&(J["MTERR") W @(EM) G END
        I (I\1024#2)&(J["MTERR") S SW='SW,BNUM=BNUM+1,$ZT="FFERR^%FGT" G WS
        S FGZA=I,FGZE=J D DISPER^%TDN G END1
BF      S $ZT="BFERR^%FGT"
        I NUM'<BNUM S NUM=BNUM
        E  S NUM=NUM+1
        F R=1:1:NUM U %TD:(1024:SW*1024) W *1 S SW='SW,BNUM=BNUM-1
        U %TD:(1024:SW*1024) W *6 S SW='SW,BNUM=BNUM+1
        G WS
BFERR   S I=$ZA,J=$ZE
        W !!,?10,"TAPE ERROR DURING BACKWARDS BLOCK READ AT BLOCK :",BNUM
        W !,?10,"$ZA = ",I,"   $ZE = ",J
        S EX=1 Q
GETBLK  S $ZT="GETERR^%FGT"
        U %TD:(1024:SW*1024) W *6
GET1    U 63:(2-SW:1) S SW='SW S BNUM=BNUM+1 Q
GETERR  I ($ZA\16384#2)&($ZE["MTERR") S EX=1 U 0 W @(EM) Q
        I ($ZA\1024#2)&($ZE["MTERR") S $ZT="GETERR^%FGT" G GET1
        S FGZA=$ZA,FGZE=$ZE D DISPER^%TDN S EX=1 Q
ERROR   S I=$ZA,J=$ZE U 0
        S BNUM=BNUM+1
        I (I\16384#2)&(J["MTERR") W @(EM) G END
        S FGZA=I,FGZE=J D DISPER^%TDN G END1
        Q
