%GS1    ;FDN;11-JUN-80;SECOND HALF OF GLOBAL SAVE
        W !,*7,"This subroutine should be run using the Global Save routine %GS.",!,*7 Q
%ST     U 0 K %DX,%CK,FLG S %NAM=$ZS(^UTILITY($J,%NAM)) I %NAM="" S POS=1 U %IOD W:%CTC "**","**" W:'%CTC "**",!,"**",! G %END
        S GLREF=^UTILITY($J,%NAM)
        I GLREF="" U 0 W !,%NAM U %IOD S %CK="" G %WT
        U 0 W !,%NAM,"(",GLREF U %IOD S %FR=""
        S F=0 F I=1:1 S F=$F(GLREF,",",F) Q:'F  S ST(I)=$P($P(GLREF,",",I),"-",1),EN(I)=$P($P(GLREF,",",I),"-",2) I EN(I)="" S EN(I)=ST(I)
        S LNO=I-1
        F I=1:1:LNO I ST(I)'=""&(ST(I)'?.N)!(EN(I)'=""&(EN(I)'?.N)) S FLG(I)=""
        F I=1:1:LNO S:ST(I)="" ST(I)=-1 S:EN(I)="" EN(I)=-1 S II(I)=ST(I) I ST(I)=-1 D %FSUB
%PRINT  S GLN="^"_%NAM_"(",LCT=LNO
        F I=1:1:LCT S Y=II(I) D:Y["""" %FIXQ S GLN=GLN_""""_Y_"""" I I<LCT S GLN=GLN_","
        S V=GLN_")",DD=$D(@V)
%ER2    I DD#2 S IN=@V,S=$P(GLN,"(",2),%DX="" D:CHK CHK S POS=2 D %FR S TEMP="("_S_")" W:%CTC TEMP,IN W:'%CTC TEMP,!,IN,!
        I %DTY["MT" U %IOD I @%MTEOT G EOT^%GS
        I $E(GLREF,$L(GLREF))=")" G %SKIP
        I DD<10 G %SKIP
        S VS=GLN_",",L=0,S="",X=$N(@(VS_"-1"_")")),GLN=$P(VS,"(",2)
%NEXT   I L S S=S_","
        S Y=X D:X["""" %FIXQ S S=S_""""_Y_"""",L=L+1,AR(L)=""""_Y_"""",D=$D(^(X))
%ER4    I D#2 S IN=^(X) D %SHO
        I %DTY["MT" U %IOD I @%MTEOT G EOT^%GS
        I D<9 S X=$N(^(X)) G %FIX
        S X=$N(^(X,"-1")) I X'=-1 G %NEXT
%FUL    S X=$N(@(VS_S_")"))
%FIX    S L=L-1,S="" F I=1:1:L S:I-1 S=S_"," S S=S_AR(I)
        I X'=-1 G %NEXT
        I S="" G:'$D(%CK) %SKIP S POS=3 W:%CTC "*","*" W:'%CTC "*",!,"*",! G %ST
        G %FUL
%FIXQ   S F=0 F K=1:1 S F=$F(Y,"""",F) Q:'F  S Y=$E(Y,1,F-1)_""""_$E(Y,F,999),F=F+1
        Q
%SHO    D:CHK CHK S POS=4,%DX="" D %FR S TEMP="("_GLN_S_")" W:%CTC TEMP,IN W:'%CTC TEMP,!,IN,! Q
%SKIP   S II(LCT)=$N(@V) I II(LCT)=-1 G %BSUB
        I EN(LCT)=-1 G %PRINT
        I '$D(FLG(LCT))&(II(LCT)'>EN(LCT))&(II(LCT)'<ST(LCT)) G %PRINT
        I $D(FLG(LCT))&(II(LCT)']EN(LCT)) G %PRINT
%BSUB   S LCT=LCT-1 I LCT<1 U 0 W:'$D(%DX) !,"Specified partial global reference ",%NAM,"(",GLREF," not defined",! U %IOD G:'$D(%DX) %ST S POS=5 W:%CTC "*","*" W:'%CTC "*",!,"*",! G %ST
        S GLN="^"_%NAM_"("
        F I=1:1:LCT S Y=II(I) D:Y["""" %FIXQ S GLN=GLN_""""_Y_"""" I I<LCT S GLN=GLN_","
        S GLN=GLN_")",II(LCT)=$N(@GLN) I II(LCT)=-1 G %BSUB
        I '$D(FLG(LCT))&(EN(LCT)'=-1)&(II(LCT)>EN(LCT)) G %BSUB
        I '$D(FLG(LCT))&(ST(LCT)'=-1)&(II(LCT)<ST(LCT)) G %BSUB
        I $D(FLG(LCT))&(EN(LCT)'=-1)&(II(LCT)]EN(LCT)) G %BSUB
        F I=LCT+1:1:LNO S II(I)=ST(I) I ST(I)=-1 D %FSUB
        G %PRINT
%FSUB   S GLN="^"_%NAM_"(" I EN(I)=-1 K FLG(I)
        F J=1:1:I S Y=II(J) D:Y["""" %FIXQ S GLN=GLN_""""_Y_"""" I J<I S GLN=GLN_","
        S GLN=GLN_")",II(I)=$N(@GLN) I II(I)'=-1&(II(I)'?.N) S FLG(I)=""
        Q
%WT     S GLN="^"_%NAM,S=""
%ER6    S IN="" S:$D(@GLN)#2 IN=@GLN D:CHK CHK S POS=6 W:%CTC GLN,IN W:'%CTC GLN,!,IN,!
        I %DTY["MT" U %IOD I @%MTEOT G EOT^%GS
        S VS=GLN_"(",L=0,X=$N(@(VS_"-1"_")")) I X=-1 S POS=7 W:%CTC "*","*" W:'%CTC "*",!,"*",! G %ST
        S GLN="" G %NEXT
%END    U 0 I $D(%IOD) C:%IOD'=$I %IOD
        Q
CHK     I IN?.E1C.E F I=0:1:31,127 I IN[$C(I) G REMOV
        Q
REMOV   U 0 W !,"^",%NAM,"(",S,")=",IN,!?5,"Control character ",I," in position ",$F(IN,$C(I))-1
        S IN="Control characters in data, data not saved" W !?5,IN S %CT=0 U %IOD Q
%FR     I $D(%FR)&('$D(%CK)) S TEMP="^"_%NAM W:%CTC TEMP,"" W:'%CTC TEMP,!,"",! K %FR
        Q
