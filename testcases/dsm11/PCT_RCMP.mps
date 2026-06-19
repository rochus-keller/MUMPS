%RCMP   ;GSK 8/15/78 - ROUTINE COMPARE:UPDATED 6-JUN-80 ; FDN
        S $ZE="ERROR^%RCMP" G PASS1
%ST     S D=0
%RCMP3  U %IOD
        W #,!!,"Routine Compare of '"_N1_"' and '"_N2_"' at " D ^%T W " on " D ^%D W !!
%RCMP2  S L1=1,L2=1
LOOP    I ^UTILITY($J,1,L1)'=^UTILITY($J,2,L2) D DIFF
        G END:^UTILITY($J,1,L1)=""
        S L1=L1+1,L2=L2+1 G LOOP
DIFF    D %RCMP3:$D(D)=0 W !,"***********************",!
        S P(1)=L1,P(2)=L2,P=0,D=D+1
DL      S P=P+1#2,A=P+1,P(A)=P(A)+1 S:^UTILITY($J,A,0)'>P(A) P(A)=^UTILITY($J,A,0) I ^UTILITY($J,A,P(A))="" S A2=P+1#2+1,P(A2)=^UTILITY($J,A2,0) S J=P(1),K=P(2) G DONE
DL2     S J=P(1) F K=L2:1:P(2) G DONE:^UTILITY($J,1,J)=^UTILITY($J,2,K)
        S K=P(2) F J=L1:1:P(1) G DONE:^UTILITY($J,1,J)=^UTILITY($J,2,K)
        G DL
DONE    S P(1)=J,P(2)=K F Z=L1:1:P(1) S LI=^UTILITY($J,1,Z) D LINE W ?2,Z,")",?7,B,?17,C,!
        W !,"--------",! F Z=L2:1:P(2) S LI=^UTILITY($J,2,Z) D LINE W ?2,Z,")",?7,B,?17,C,!
        W !,"***************",! S L1=P(1),L2=P(2) Q
LINE    S B="",C="" Q:LI=""  S B=$P(LI," ",1),Q=$F(LI," "),C=$E(LI,Q,255) Q
PASS1   R !,"Enter first routine name: ",%PN G:%PN=""!(%PN="^") %EXIT
        G:%PN="?" Q1 I %PN="^D" D %LST^%RD G PASS1
        K N1 D %CNAME S N1=%PN
PASS1A  R !,"Enter second routine name: ",%PN G:%PN=""!(%PN="^") PASS1
        G:%PN="?" Q2 I %PN="^D" D %LST^%RD G PASS1+3
        I %PN=N1 W !?5,"Same routine.  Please choose another, or enter '?' for more information." G PASS1A
        D %CNAME S N2=%PN
PASS2   S %TRM=$I,%QTY=2 K %DEF D ^%IOS K %DTY I '$D(%IOD) K %TRM G PASS1A
        S X1="ZL @N1 S N=1 X X2 ZL @N2 S N=2 X X2"
        S X2="F I=1:1 S ^UTILITY($J,N,I)=$T(+I) I $T(+I)="""" S ^UTILITY($J,N,0)=I Q"
        X X1
        G %RCMP+2
%CNAME  X "ZL @%PN" Q
ERROR   I $ZE["<NOPGM" W !?5,*7,"Routine ",%PN," not found in directory",! S $ZE="ERROR^%RCMP" G:$D(N1) PASS1A G PASS1
        W !,$ZE,! G %EXIT
Q1      W !?5,"Enter the name of the first routine you want to compare.",! D QUES G PASS1
Q2      W !?5,"Enter the name of the routine you wish to compare ",N1," to.",! D QUES G PASS1A
QUES    W ?5,"Enter ^D to list all routines in this UCI.",!
        W ?5,"Enter <CR> or ^ to back up to previous question.",! Q
END     W !!,"A total of ",D," differences found.",!!
%EXIT   U 0 I $D(%IOD) C:%IOD'=%TRM %IOD
        K B,D,N,N1,N2,%IOD,%PN,%TRM,X1,X2,L1,L2,P,I,J,K,Z Q
