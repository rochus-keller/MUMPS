%GRTS   ;27-Feb-85;Send Routines or Globals to another CPU with %GRTR;DSM V3 ;DMW
        S DSP=0,DIR="S" D ^%GRTINI
S       S END="U ME W:DEV'=$I "" **Sent**"",! U DEV",NOSEND="Nothing chosen to send"
        S TSYNC="F K=1:1:MAX W SYNC,RET R X:T1 I X=SYNC Q"
        S CHK="S CHK1=0 F L=1:1:$L(X) S CHK1=CHK1+$A(X,L)"
        S RNUM="S CHK1=J_""^""_CHK1"
        S ENQU="F B=1:1:TRIES X BUFLUSH W ENQ,RET R A:T1 Q:A=AA  S JJ=$P(A,""^"",2),ERROR=B=TRIES W:ERROR ""(%)ERROR(%)"",RET I JJ=J
!(JJ=J-1) I A[ACK!(A[NAK) X @($P(A,""(%)"",2)_""J"") Q"
        S ACKJ="Q:'TO&(J=JJ)  S:J'=JJ AGAIN=1"
        S NAKJ="S AGAIN=1"
        S SEND="F K=1:1:TRIES S (B,AGAIN)=0 W $S(DONE&EOR:EOT,EOR:ETX,ERROR:""ERROR"",1:X),RET Q:EOR!ERROR  X CHK,RNUM W CHK1,RET S
ERROR=K=TRIES,AA=ACK_""^""_J R A:T1 S TO=$T Q:A=AA  S AGAIN=A=(NAK_""^""_J) X:'AGAIN ENQU Q:'AGAIN"
        W ! U DEV G @(DIR_MOD)
SR      ;
        S RB="U ME W:DEV'=$I !,""Routine "",N,"" being transferred"" U DEV"
        S RTSEND="F J=1:1 S X=$T(+J),EOR=X="""" X SEND Q:ERROR!EOR"_DSP4
        S RTSND="S N=$O(^UTILITY($J,"""")) Q:N=""""  F I=1:1 S EOR=0,M=$O(^UTILITY($J,N)),DONE=M="""" X TSYNC Q:K=MAX  ZL @N S X=N,J
=0 X SEND"_DSP2_" X RTSEND"_DSP3_" Q:DONE  S N=M"
        X RTSND
        G SCHECK
SG      ;
        S GB="U ME W:DEV'=$I ""Global "",N,"" being transferred"" U DEV",N=$O(^UTILITY($J,"")) G SCHECK:N=""
        S GLS0="F J=1:1 S EOR=X="""" X SEND Q:ERROR!EOR "_DSP1_" S X=@X,J=J+1 X SEND Q:ERROR "_DSP1_" S (X,ZO)=$ZO(@ZO)"
        F I=1:1 S M=$O(^UTILITY($J,N)),DONE=M="" X TSYNC Q:K=MAX  X:'DSP GB D GLSND Q:Y'=""  X:'DSP END Q:DONE  S N=M
        G SCHECK
GLSND   S (EOR,A)=0,Y="",(X,N,ZO)="^"_N
        Q:'$D(@N)  S:'($D(@N)#10) (X,ZO)=$ZO(@ZO)
        X GLS0 I ERROR W "(%)ERROR(%)"_RET
GLSQ    Q
SCHECK  ;
        K ^UTILITY($J) U ME W !!,$S($ZE["DSCON":DSCON,K=MAX:NOLINK,K=TRIES:NOSYNC,1:GOOD),!!!
        K (DEV) Q
