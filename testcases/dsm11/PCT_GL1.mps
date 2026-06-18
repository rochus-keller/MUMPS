%GL1    ;FDN;12-JUN-80;PART OF GLOBAL LISTER TO DO PARTIAL GLOBALS
        W !,*7,"This subroutine should be run using the Global List utility %GL.",!,*7 Q
%START  S F=0,GL=%GN,%BAR="\" F I=1:1 S F=$F(GLREF,",",F) Q:'F  S ST(I)=$P($P(GLREF,",",I),"-",1),EN(I)=$P($P(GLREF,",",I),"-",2) I
EN(I)="" S EN(I)=ST(I)
        W !! S LNO=I-1,%LIN=%LIN+2
        F I=1:1:LNO I ST(I)'=""&(ST(I)'?1.N.1".".N)!(EN(I)'=""&(EN(I)'?1.N.1".".N)) S FLG(I)=""
        F I=1:1:LNO S:ST(I)="" ST(I)=-1 S:EN(I)="" EN(I)=-1 S II(I)=ST(I) I ST(I)=-1 D %FSUB
%PRINT  S (GLN,GLW)="^"_GL_"(",LCT=LNO
        F I=1:1:LCT S Y=II(I) D:Y["""" %FIXQ S GLW=GLW_""""_II(I)_"""",GLN=GLN_""""_Y_"""" I I<LCT S GLN=GLN_",",GLW=GLW_","
        S V=GLN_")",W=GLW_")"
        S DD=$D(@V)
        I DD#2 S IN=@V S %LC=1 D %LIN W W," = " D %OUT S %DX="" G:$D(%STP) %START
        I $E(GLREF,$L(GLREF))=")" G %SKIP
        I DD<10 G %SKIP
        S VS=GLN_",",L=0,(S,SS)="",X=$N(@(VS_"-1"_")"))
%NEXT   I L S S=S_",",SS=SS_","
        S Y=X,SS=SS_""""_X_"""" D:X["""" %FIXQ S S=S_""""_Y_"""",L=L+1,AR(L)=""""_Y_"""",D=$D(^(X))
        I D#2 S IN=^(X) D %SHO G:$D(%STP) %START
        I D<9 S X=$N(^(X)) G %FIX
        S X=$N(^(X,"-1")) I X'=-1 G %NEXT
%FUL    S X=$N(@(VS_S_")"))
%FIX    S L=L-1,(S,SS)="" F I=1:1:L S:I-1 (S,SS)=S_"," S (S,SS)=S_AR(I)
        I X'=-1 G %NEXT
        I S="" G @$S($D(%CK):"%QUIT",1:"%SKIP")
        G %FUL
%FIXQ   S F=0 F K=1:1 S F=$F(Y,"""",F) Q:'F  S Y=$E(Y,1,F-1)_""""_$E(Y,F,999),F=F+1
        Q
%SHO    W GLW,$S($D(%CK):"(",1:","),SS,") = " D %OUT S %DX="" Q
%SKIP   S II(LCT)=$N(@V) I II(LCT)=-1 G %BSUB
        I EN(LCT)=-1 G %PRINT
        I '$D(FLG(LCT)),(II(LCT)'>EN(LCT)),(II(LCT)'<ST(LCT)) G %PRINT
        I $D(FLG(LCT)),(II(LCT)']EN(LCT)) G %PRINT
%BSUB   S LCT=LCT-1 I LCT<1 U 0 W:'$D(%DX) !,"SPECIFIED PARTIAL GLOBAL REFERENCE ",GL,"(",GLREF," NOT DEFINED",! U %IOD Q
        S GLN="^"_GL_"("
        F I=1:1:LCT S Y=II(I) D:Y["""" %FIXQ S GLN=GLN_""""_Y_"""" I I<LCT S GLN=GLN_","
        S GLN=GLN_")",II(LCT)=$N(@GLN) I II(LCT)=-1 G %BSUB
        I '$D(FLG(LCT))&(EN(LCT)'=-1)&(II(LCT)>EN(LCT)) G %BSUB
        I '$D(FLG(LCT))&(ST(LCT)'=-1)&(II(LCT)<ST(LCT)) G %BSUB
        I $D(FLG(LCT))&(EN(LCT)'=-1)&(II(LCT)]EN(LCT)) G %BSUB
        F I=LCT+1:1:LNO S II(I)=ST(I) I ST(I)=-1 D %FSUB
        G %PRINT
%FSUB   S GLN="^"_GL_"(" I EN(I)=-1 K FLG(I)
        F J=1:1:I S Y=II(J) D:Y["""" %FIXQ S GLN=GLN_""""_Y_"""" I J<I S GLN=GLN_","
        S GLN=GLN_")",II(I)=$N(@GLN) I II(I)'=-1&(II(I)'?.N) S FLG(I)=""
        Q
%WT     S GLW="^"_GL
        S %LC=2 D %LIN W GLW I $D(@GLW)#2 S IN=@GLW I IN'="" W " = " D %OUT
        S %LC=1 D %LIN G:$D(%STP) %START S VS=GLW_"(",L=0,(S,SS)="",X=$N(@(VS_"-1"_")")) I X=-1 Q
        G %NEXT
%OUT    I '%DCC!'(IN?.E1C.E) W IN G %OUT1
        D:%DCC=1 %DSP1 D:%DCC=2 %DSP2
%OUT1   S %LC=1 D %LIN Q
%DSP1   F I=1:1:$L(IN) S %CHR=$E(IN,I) D %WRT
        Q
%WRT    I $A(%CHR)<33 W %BAR Q
        I $A(%CHR)=92 W "\\" Q
        W %CHR Q
%DSP2   F I=1:1:4 S A(I)=""
        F I=1:1:$L(IN) S %CHR=$E(IN,I) D:$A(%CHR)<32 %CTL D:$A(%CHR)'<32 %NML
        S %FCR=1,%NLN=($L(IN)-1)\%NCR+1
        F I=1:1:%NLN S %LCR=%FCR+%NCR-1 D %LST
        Q
%CTL    S A(1)=A(1)_%BAR D %FIXO F K=2:1:4 S A(K)=A(K)_$E(%ASCII,K-1)
        Q
%NML    S A(1)=A(1)_%CHR D %FIXO F K=2:1:4 S A(K)=A(K)_$E(%ASCII,K-1)
        Q
%FIXO   S %ALN=3-$L($A(%CHR)),%ASCII=$A(%CHR) F M=1:1:%ALN S %ASCII="0"_%ASCII
        Q
%LST    I %SC D:%LIN+4>%PAG %SC
        F %J=1:1:4 S %LC=1 D %LIN W ?3,$E(A(%J),%FCR,%LCR)
        S %LC=1 D %LIN S %FCR=%LCR+1
        Q
%LIN    I %SC D:%LIN+%LC>%PAG %SC S %LIN=%LIN+%LC
        F %K=1:1:%LC W !
        Q
%SC     U 0 R !,"Type <CR> to continue",%X:60 S:'$T %X="^" U %IOD S %LIN=0 Q
