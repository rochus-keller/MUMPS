SDCCOPY ;
        I '$V($V(44)+35) W "*** System not in baseline mode ***",! Q
START   D ^DAT,^TIM V $V(44)+204::65535
RESTRT  K  S $ZE="",BF=0 W ! C 63 S ST=$V(44)
CVASK   S QUES="CVQ",DEF="" X ^%Q("ASK") G DOVER:ANS="V"
        I ANS="E" C 63 Q
        I ANS'="C" D CVQH G CVASK
DOCOP   S COPSW=1,VFSW=0
        D GETUNITS I %A W !! G CVASK
        G SETVRS
DOVER   S VFSW=1,COPSW=0
        D GETUNITS I %A W !! G CVASK
SETVRS  C 63 O 63
        V ST+70::$V(ST+70)#256
        U 63:(::"CTZ") V 0:FD S ZA=$ZA U 63:(::"C"),0 G:ZA\64#2 MX
        D MINSBB
        I 'COPSW U 63:(::"CZT") V 0:TD S ZA=$ZA U 63:(::"C"),0 G:ZA\64#2 VX D INSBB G NOLBWRT
        C 63 O 63:2 U 63:(2:1),0
        S FMTSIZ=$P(%D," ",8)*$P(%D," ",9)*$P(%D," ",10),DDU=TD,%B=0
        D SDCENT^DPBBSET
        I %ER W " of Copy disk" G XX3
        F I=1:1:%B I %B(I)<98 G BBABORT
        U 63:(1:1:"Z"),0 V 0:FD U 63:(1:2:"C"),0 F I=512:2:711 V I:0:$V(I+1024,0)
        D INSBB K %B
        U 63:(1:1:"CZT") V -16777216:TD S ZA=$ZA\64#2 U 63:(::"C"),0 I ZA G ZERR
NOLBWRT ;
        I BF C 63 O 63:BF G COPY
        S BF=$V($V(44)+32)-4 S:BF<2 BF=2 S:BF>11 BF=11
GBUF    C 63 O 63:BF:1 E  S BF=BF-1 G GBUF
COPY    S SZ=%MP*400
        G:'COPSW VERFY W !,"Begin copy " D TIM W "... "
        F I=1:BF:SZ-BF V I:FD,-I:TD
        S I=I+BF I I<SZ U 63:(1:SZ-I),0 V I:FD,-I:TD
VERFY   G:'VFSW ASKMOR W !,"Begin verify " D TIM W "... "
        U 63:(1:1:"Z"),0 V 0:FD U 63:(2:1),0 V 0:TD U 63:(1:2:"C"),0
        S N=0
        S K=0 F I=0:2:511,712:2:1023 I $V(I,0)'=$V(I+1024,0) D VFAIL G XX3
        U 63:(1:BF),0 S CHNK=BF
        F K=1:BF:SZ-BF U 63:(::"C"),0 V K:FD U 63:(::"VT") V K:TD S ZA=$ZA\64#2 U 0 I ZA D VCHNK G XX3
        S K=K+BF,CHNK=SZ-K I CHNK>0 D VCHNK G:ZZ XX3
ASKMOR  C 63 W " completed " D TIM,DISMOUNT W ! G RESTRT
VCHNK   U 63:(1:1),0
        F N=0:1:CHNK-1 U 63:(::"C"),0 V K+N:FD U 63:(::"VT") V K+N:TD S ZZ=$ZA\64#2 U 0 I ZZ D VFAIL Q
        S N=0 U 63:(1:BF:"C"),0 Q
TIM     S H=$P($H,",",2),T1=H\3600,T2=H#3600\60,H=H#60
        S:T2<10 T2=0_T2 S:H<10 H=0_H W T1,":",T2,":",H Q
VFAIL   W !,"DSM Relative Blk # ",K+N," failed to verify",! Q
MINSBB  S %DT=FDT G INS2
INSBB   S %DT=TDT
INS2    V %DT::$V(%DT)#16384+16384
        S MM=$V(%DT)\256#64+$V($V(44)+86)
        F I=0:2:190 V I:MM:$V(512+I,0)
        V %DT+2::%MP Q
DISMOUNT        V FDT::$V(FDT)#16384
        V FDT+2::0
        V TDT::$V(TDT)#16384
        V TDT+2::0
        Q
BBABORT W !!,"** ""COPY"" DISK HAS BAD-BLOCK WITHIN SYSTEM-IMAGE AREA"
        W !,"  -- YOU CANNOT USE THIS DISK.",!!
        G XX3
ZERR    W !,"Unable to write block #0 of Copy, please check that drive is ready." G XX3
GETUNITS        ;
GM      O 63 S PRM="MASTER disk is mounted",MAPS=0,M=0 D GETYU^DPBEGIN
        S:'$D(%A) %A=1 G:%A EXGU
        S FD=DDU,FDT=%DT,F=%D
GT      S PRM=$S(COPSW:"COPY disk is mounted",1:"VERIFY disk mounted") D GETYU^DPBEGIN
        S:'$D(%A) %A=1 G:%A GM
        S TD=DDU,TDT=%DT
        I TD=FD W !,"The master and copy disks can not be the same disk",! G GM
        I $P(F," ")'=$P(%D," ") W !,"The master and copy disk must be identical disk types",! G GM
        V FDT::$V(FDT)#256+(3*256),192:$V(ST+86):0
        V TDT::$V(TDT)#256+(6*256),384:$V(ST+86):0
EXGU    Q
CVQ     W "Do you wish to Copy, Verify, or End  [ C, V, or E ]  " Q
CVQH    W !,"Enter",?7,"C  to do a copy,",!
        W ?7,"V  to just verify that two disks are identical,",!
        W ?7,"   or type E if you wish to exit this program."
        W ! Q
MX      D XX W "Master" G XX2
VX      D XX W "Verify" G XX2
XX      U 0 W !,"Unable to read block #0 of " Q
XX2     W " disk"
XX3     D DISMOUNT G RESTRT
