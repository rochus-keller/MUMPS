%SUM2   ;PRINT SUMMARY : JEC ; 22-SEP-80  1:32 PM
        O %IO U %IO D:IOO'=%IO ^%HDR S S=0,%HED=1,PRT=%DTY="LP",W="S" D SB2 G END:'E
A1      F K=1:1:4 S Y=$P("G,P,A,V",",",K),N=999,L1=2,L2=8,SW=1 D:$Y>54 SB3:'SWT,SB4:SWT D SB1 S N=999,L1=1,L2=1 D SB1
        W !!,"VIEW USED" S J=0 F I=S+1:1:R S J=J+INC I $D(P(I)),$D(^UTILITY("SUM1",%JB,P(I),0,"VIEW")) W:INC=1 ?J-1*10+18 W:INC=2 ?J+10 W "*"
        W !!,"$VIEW USED" S J=0 F I=S+1:1:R S J=J+INC I $D(P(I)),$D(^UTILITY("SUM1",%JB,P(I),0,"$VIEW")) W:INC=1 ?J-1*10+18 W:INC=2
?J+10 W "*"
        W !!,"NAKED USED" S J=0 F I=S+1:1:R S J=J+INC I $D(P(I)),$D(^UTILITY("SUM1",%JB,P(I),0,"NAKED")) W:INC=1 ?J-1*10+18 W:INC=2
?J+10 W "*"
        I T>R S R=R+PGM,S=S+PGM S:R>T R=T G A1
END     Q
SB1     S N=$N(^UTILITY("SUM1",%JB,0,Y,N)) Q:N<0  I $L(N)<L1!($L(N)>L2) G SB1
        I $Y>60!(K=1&SW)!%HED D SB3:'SWT,SB4:SWT
        S I=S,J=0 W:K>1&SW !!,$P("^ROUTINE^ARRAY^VARIABLE","^",K),!,$P("^-------^--------^-----","^",K) W !,N S SW=0
S1      S I=I+1,J=J+INC G SB1:'$D(P(I)),SB1:I>R S IN=P(I) G S1:'$D(^UTILITY("SUM1",%JB,IN,Y,N)) S X=^(N)
        W:INC=1 ?J-1*10+18 W:INC=2 ?J+10 I K'=2 W:X[W "*" W:X'[W "R" G S1
        F M=1:1:5 S Z=$P("C,O,L,F,J",",",M) I X[Z S:Z="J" Z="S" W Z
        G S1
SB2     S (E,T,TN)=0 K P Q:'$D(^UTILITY("SUM1",%JB,0,0))  S NAM=^(0)
S2      S T=T+1,TN=$N(^UTILITY("SUM1",%JB,TN)) I TN'=-1,$D(^UTILITY("SUM1",%JB,TN,0)) S P(T)=TN,E=E+1 G S2
        S T=T-1 Q:'E  S CRE=^UTILITY("SUM",%JB),%DT=+CRE D %CDS^%H S %T=$P(CRE,",",2),CRE=%DAT1 D TIM D INT^%D,INT^%T S HEAD=" created on "_CRE_" at "_TIM_"     printed on "_%DAT1_" at "_%TIM1
        I T>6&'PRT!(T>12&PRT) S SWT=1,INC=2,PGM=60 S:'PRT PGM=33 S R=PGM S:R>T R=T Q
        S SWT=0,INC=1,PGM=12 S:'PRT PGM=6 S R=PGM S:R>T R=T Q
SB3     W # H 2 W NAM,?18,"   ",HEAD,! S (SW,%HED)=0
        W !,$P("GLOBAL^ROUTINE^ARRAY^VARIABLE","^",K) S J=4 F I=S+1:1:R S J=J+10 W ?J+(8-$L(P(I))\2),P(I)
        W !,$P("------^-------^-----^--------","^",K) S J=4 F I=S+1:1:R S J=J+10 W ?J,"--------"
        Q
SB4     W # H 2 W NAM,?18,"   ",HEAD,! S (SW,%HED)=0
        F C=1:1:8 S J=0 W ! F I=S+1:1:R S NME=$E("        ",1,8-$L(P(I)))_P(I),J=J+INC,M=$E(NME,C) W:M'="" ?J+10,M
        W *13,$P("GLOBAL^ROUTINE^ARRAY^VARIABLE","^",K),!,$P("------^-------^-----^--------","^",K) S J=0 F I=S+1:1:R S J=J+INC W ?J+10,"-"
        Q
TIM     S %M=%T\60,%N=$E("AP",%M\720+1)_"M",%M=-%M\720*720+%M,%H=%M\60,%M=-%H*60+%M
        S:'%H %H=12 S:%H<10 %H=" "_%H S:%M<10 %M=0_%M S TIM=%H_":"_%M_" "_%N Q
Z       P %SUM2 ZS %SUM2
