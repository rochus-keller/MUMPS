%GRTR   ;27-Feb-85;Receive routines/globals from %GRTS;DSM V3 ;DMW
        S DSP=0,DIR="R" D ^%GRTINI
R       S GET="F K=1:1 R X:T1 S RSLT=$S('$T:-1,X=ENQ:0,X=ETX:2,X=""(%)ERROR(%)"":3,X=SYNC:3,X=EOT:4,1:1),ERROR=RSLT=3 Q:RSLT>1  W:'R
SLT XX,RET I RSLT R CHK1:T1 X CHK S XX=$S(OK:ACK,1:NAK)_""^""_J X BUFLUSH W XX,RET Q:OK"
        S CHK="S CHK2=0,OK=$S($L(X):0,$P(CHK1,""^"",2):0,1:1) F L=1:1:$L(X) S CHK2=CHK2+$A(X,L) S OK=CHK2=$P(CHK1,""^"",2)"
        S REM="ZR:MOD=""R""&ERROR"
        S END="U ME W:DEV'=$I "" **Received**"",! U DEV"
        S RSYNC="F K=1:1:MAX R X:T1 I X=SYNC W SYNC,RET Q"
        U DEV G @(DIR_MOD)
RR      ;
        S RB="U ME W:DEV'=$I ""Routine "",N,"" being transferred"" U DEV"
        S RTGET="F J=1:1 X GET Q:RSLT>1 "_DSP1_" ZI X"
        X "F I=1:1 X RSYNC Q:K=MAX  S J=0 X GET Q:ERROR  S N=X ZR "_DSP2_" X RTGET ZR:ERROR  Q:ERROR "_DSP3_" ZS @N Q:RSLT=4"
        X REM D RCHECK Q
RG      ;
        S GB="U ME W:DEV'=$I !,""Global "",$P(X,""(""),"" being transferred"" U DEV"
        S GLGET="F J=1:1 X GET I RSLT'=-1 Q:RSLT>1  "_DSP1_" X:J=1 GB S Y=X X GLGET2 Q:RSLT>1"
        S GLGET2="S J=J+1 F Q=1:1 X GET I RSLT'=-1 "_DSP1_" S @Y=X Q"
        F I=1:1 X RSYNC Q:K=MAX  X GLGET Q:ERROR  X:'DSP END Q:RSLT=4
RCHECK  ;
        U ME W !!,$S($ZE["DSCON":DSCON,K=MAX:NOLINK,ERROR:NOSYNC,1:GOOD),!!!
        K (DEV) Q
