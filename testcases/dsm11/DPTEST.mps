DPTEST  ;
        U 0 W !!,"To format, test, or initialize a disk, type:",!
        W "D ^DISKPREP",!
QUIT    Q
COPENT  S SHOW=0 G DOIT
TAPENT  ;
DISKENT S SHOW=1
DOIT    I '%TST G NXTP
        D START I %A G STOP
NXTP    S $ZT=%LABEL X %LOAD
ERLIN   W !,"Unexpected error ",$ZE
STOP    W !,"Cannot continue. Please re-boot and start over.",!
H       B 0 H 1 G H
START   S %T=0,%A=0,END=$P(%D," ",5)*400
        X UNBRK
        I BF\%DPT S BF=BF-(BF#%DPT)
NXTT    S %T=%T+1,BL=0,PAT=$P(%TST(%T),"/",2) G:'SHOW N1
        W:%T=1 !,"(You may hit the ""ESC"" key at any time to determine "
        W:%T=1 "the number of",!,"blocks  processed so far)",!
        D SETTI W !,TI,?13,"Begin test pattern  ",$P(%TST(%T),"/",1),!
N1      S BN=BF
FILBF   U 63:(1:1:"CZT") F I=0:2:1023 V I:0:PAT
FILL    S II=0 F I=1:1:5 V:BL -BL:DDU V:'BL -16777216:DDU I $ZA\64#2 S II=II+1
        I II>1 G BAD0
FILL1   F I=2:1:BF U 63:(I:1) V BL:DDU G FILL:$ZA\64#2
        U 63:(1:BN)
        G NEXTC:BL=BN
ENDCHK  U 63:(1:BN) I BL+BN>END S BN=END-BL U 63:(1:BN)
DOTST   V:BL -BL:DDU V:'BL -16777216:DDU G CHNKE:$ZA\64#2 S BL=BL+BN
NEXTC   D ESCP G EXIT:GO,ENDCHK:BL<END
        S %TST=%TST-1 G NXTT:%TST
        G:'SHOW EXIT D SETTI W !,TI
        W ?13,"Testing complete",!! G EXIT
CHNKE   S J=0
TST1    U 63:(1:1) F II=1:1:3 V:BL -BL:DDU V:'BL -16777216:DDU I $ZA\64#2 G BADB
SNGL    S J=J+1,BL=BL+1
        I J'<BN U 63:(1:BF) G NEXTC
        D ESCP G:GO EXIT G TST1
BADB    U 0 S BAD=BL G:'SHOW CHKBB W " *** Test failed - DSM relative blk #  "
        W BAD,"  on this disk is bad",!
        G:%TY!%B CHKBB W "You should not use this RK05 disk pack!"
        W "(But test will continue anyway)",!
CHKBB   F M=1:1:%B I BAD=%B(M) W:SHOW " -- already in table",! G SNGL
        I %B'<$P(%D," ",12) W !," *** bad block table is full ***",! G TRM
        W:SHOW " -- adding to bad block table",!
        I %MP*400+%B=BAD S %B=%B+1,%B(%B)=16777215
        S %B=%B+1,%B(%B)=BAD G SNGL
ESCP    S GO=0 U 0 R *ES:0 Q:ES<0  G ESCP:ES'=27&(ES'=$A("?"))
        W !,?3,BL," blocks processed so far,   ",END-BL," to go",!
AG4     W !?3,"Type <RETURN> to proceed with testing, or ""^"" to terminate",!?3
        R "testing and proceed to next step of disk preparation > ",GO,!
        S GO=GO="^" I GO W !?5,"----- Testing terminated by operator",!
        Q
RESET   X WFIX C 63 O 63 Q
BAD0    U 0 W !,"!! can't write block #0 of this disk!",!
        W "Perhaps the disk is off line or is not write-enabled",!
        I $P(%D," ",6)="Y"&'%FMT W "(? Perhaps it has never been formatted ?)",!
TRM     W "Testing terminated after ",BL," blocks",! D RESET S %A=1 Q
SETTI   S H=$P($H,",",2),T1=H\3600,T2=H#3600\60,H=H#60
        S:T2<10 T2=0_T2 S:H<10 H=0_H S TI=$J(T1_":"_T2_":"_H,8) K T2,T1,H Q
EXIT    U 0 K END,TI,ES,%T,BN,%TST,%FMT
        D RESET Q
