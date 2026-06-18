%PCMP   ;19-Nov-82 ;UTILITY ;PROGRAM MAINTENANCE ;COMPARES TWO PROGRAMS ;JHM
        G PASS1
%ST     S D=0
%RCMP3  U %IOD
        W #,!!,"Routine Compare of '"_N1_"' and '"_N2_"' at " D ^%T W " on " D ^%D W !!
%RCMP2  S L1=1,L2=1
LOOP    I ^UTILITY($J,1,L1)'=^UTILITY($J,2,L2) D DIFF
        G END:^UTILITY($J,1,L1)=""
        S L1=L1+1,L2=L2+1 G LOOP
DIFF    D %RCMP3:$D(D)=0 W !,"***********************",!
        S P(1)=L1,P(2)=L2,P=0,D=D+1
DL      S P=P+1#2,A=P+1,P(A)=P(A)+1 S:^UTILITY($J,A,0)'>P(A) P(A)=^UTILITY($J,A,0) I ^UTILITY($J,A,P(A))="" S A2=P+1#2+1,P(A2)=^UTIL
ITY($J,A2,0) S J=P(1),K=P(2) G DONE
DL2     S J=P(1) F K=L2:1:P(2) G DONE:^UTILITY($J,1,J)=^UTILITY($J,2,K)
        S K=P(2) F J=L1:1:P(1) G DONE:^UTILITY($J,1,J)=^UTILITY($J,2,K)
        G DL
DONE    S P(1)=J,P(2)=K F Z=L1:1:P(1) S LI=^UTILITY($J,1,Z) D LINE W ?2,Z,")",?7,B,?17,C,!
        W !,"--------",! F Z=L2:1:P(2) S LI=^UTILITY($J,2,Z) D LINE W ?2,Z,")",?7,B,?17,C,!
        W !,"***************",! S L1=P(1),L2=P(2) Q
LINE    S B="",C="" Q:LI=""  S B=$P(LI," ",1),Q=$F(LI," "),C=$E(LI,Q-1,255) Q
PASS1   K ^UTILITY($J)
        R !,"Enter first program name: ",%ROU Q:%ROU=""!(%ROU="^")
        G:%ROU="?" Q1 D %EXT^%PSEL I '$D(^UTILITY($J)) G PASS1
        S N1=$O(^UTILITY($J,""))
PASS1A  K ^UTILITY($J)
        R !,"Enter second program name: ",%ROU G:%ROU=""!(%ROU="^") PASS1
        G:%ROU="?" Q2 D %EXT^%PSEL I '$D(^UTILITY($J)) G PASS1A
        S N2=$O(^UTILITY($J,""))
        I N2=N1 W !?5,"Same routine.  Please choose another, or enter '?' for more information." G PASS1A
PASS2   S %TRM=$I,%QTY=2 K %DEF D ^%IOS K %DTY I '$D(%IOD) K %TRM G PASS1A
        W !,"Begin compare:",!
        S R=0
        S T=$P($P(N1,".",2),";",1),V=$P(N1,";",2),N=$P(N1,".",1) D LOADU
        S T=$P($P(N2,".",2),";",1),V=$P(N2,";",2),N=$P(N2,".",1) D LOADU
        G %ST
Q1      W !?5,"Enter the name of the first routine you want to compare.",! D QUES G PASS1
Q2      W !?5,"Enter the name of the routine you wish to compare ",N1," to.",! D QUES G PASS1A
QUES    ;
        W ?5,"Enter <CR> or ^ to back up to previous question.",! Q
LOADU   S L=+^PRG(T,N,V,0),R=R+1
        F I=1:1 S ^UTILITY($J,R,I)=$P(^PRG(T,N,V,L),"^",3,255),L=+^PRG(T,N,V,L) I 'L S ^UTILITY($J,R,I+1)="",^(0)=I+1 Q
        Q
END     W !!,"A total of ",D," differences found.",!!
%EXIT   U 0 I $D(%IOD) C:%IOD'=%TRM %IOD G %PCMP
        K B,D,N,N1,N2,%IOD,%PN,%TRM,X1,X2,L1,L2,P,I,J,K,Z Q
