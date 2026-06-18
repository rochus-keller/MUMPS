DPFMT30 U 0 W !!,"To format, test, or initialize a disk, type: D ^DISKPREP",! Q
C1      F S=S:1:2*%DPT+S-1 V OF:0:S S OF=OF+BYS
        S T=T+1,S=S+257-(2*%DPT),TR=TR+1 I T=$P(%D," ",9) S (S,T)=0,C=C+1,NC=OF F I=OF-2:BYS:BX V I:0:C
        G:TR<TRK C1 I BL+BN>FMTSIZ S BN=FMTSIZ-BL G:'BN DONE U 63:(1:BN+%XTRA)
        V:BL -BL:DDU V:'BL -16777216:DDU I $ZA>63,$ZA\64#2 S:'NC NC=BYS+2 D CHNKER G C2
        S BL=BL+BN
C2      G:BL=FMTSIZ DONE I NC F I=0:BYS:NC-2 V I:0:C
        D ESCP G:%A DONE U 63 S OF=2,(TR,NC)=0 G C1
TAPENT  U 0
DISKENT ;
COPENT  ;
        I '%FMT G NXTP
        D START I %A G STOP
NXTP    S $ZT=%LABEL X %LOAD
ERLIN   W !,"Unexpected error ",$ZE
STOP    W !,"Cannot continue. Please re-boot and start over.",!
H       B 0 H 1 G H
START   S BL=0,%A=0,%RP=(%TY=3),C=49152*'%RP+4096
        S BN=BF-%XTRA,TRK=BN\%DPT I TRK S BN=TRK*%DPT
        S BYS=(%RP+%XTRA)*4+512,BX=BN*2-1*BYS,NC=BX+2
        I %TY'=0 W !!,"Now generating format pattern in memory" F I=0:BYS*2:BX W "." F J=I:2:BYS*2-2+I V J:0:-1
        I %RP F I=0:BYS:BYS*2*BN-1 V I+4:0:0,I+6:0:0
        S (T,S)=0,E=BYS*BN*2
        W !,"(You may hit the ""ESC"" key at any time, to determine the "
        W "number of",!,"blocks processed so far)",!!
        X UNBRK
        F I=1:1 R *ES:0 Q:ES<0
        D SETTI W TI,?13,"Begin formatting",!
        U 63:(1:BN+%XTRA:"ZFT") I %TY'=0,TRK'=0 G C2
CHUNK   G ENDCHK:%TY=0 S OF=0
SETUP   V OF:0:C,OF+2:0:T*256+S S S=S+1
        I S=%DPT*2 S S=0,T=T+1 I T=$P(%D," ",9) S T=0,C=C+1
        S OF=OF+BYS G SETUP:OF<E,DOFMT
ENDCHK  I BL+BN>FMTSIZ S BN=FMTSIZ-BL U 63:(1:BN+%XTRA)
DOFMT   V:BL -BL:DDU V:'BL -16777216:DDU I $ZA>63,$ZA\64#2 D CHNKER G CHNEXT
        S BL=BL+BN
CHNEXT  D ESCP I '%A U 63 G CHUNK:BL<FMTSIZ
DONE    D SETTI U 0 W:'%A !,TI,?13,"Formatting complete",!! G EXIT
CHNKER  S J=0
FORM1   U 63:(1:1+%XTRA) F I=1:1:3 V:BL -BL:DDU V:'BL -16777216:DDU I $ZA>63,$ZA\64#2 G SNGLER
SNGL    S J=J+1,BL=BL+1
        I J'<BN U 63:(1:BN+%XTRA) Q
        G FORM1:%TY=0
        U 63:(1:BF) F I=0:BYS:BYS V I:0:$V(BYS*2*J+I,0),I+2:0:$V(BYS*2*J+I+2,0)
        G FORM1
SNGLER  U 0 W "Error formatting DSM relative blk #  ",BL,"  on this disk",!
        G RKBAD:%TY=0
        I %B'<$P(%D," ",12) W " *** bad block table is full ***",! G NUMSTP
        W " -- adding to bad-block table",!
        S %B=%B+1,%B(%B)=BL G SNGL
NUMSTP  W "Formatting terminated after ",BL," blocks",!
        X WFIX C 63 S %A=1 Q
ESCP    U 0 R *ES:0 Q:ES<0  G ESCP:ES'=27&(ES'=$A("?"))
        W !,?3,BL," blocks processed so far,   ",FMTSIZ-BL," to go"
AG3     W !,"Type  <CR>  to proceed with formatting,",!,?7
        R "^    to terminate disk preparation  : ",GO,!
        Q:GO=""  G NUMSTP:GO="^",AG3
SETTI   S H=$P($H,",",2),T1=H\3600,T2=H#3600\60,H=H#60
        S:T2<10 T2=0_T2 S:H<10 H=0_H S TI=$J(T1_":"_T2_":"_H,8) K T2,T1,H Q
RKBAD   W "You should not use this RK05 disk pack.",! G NUMSTP
EXIT    U 63:(1:BF:"C"),0
        B 1 K C,T,S,BYS,%RP,E,BX,NC,TR,TRK
        Q
