%OVR    ;Print a structure diagram for a set of routines : JEC ; 25-NOV-80 10:34 PM
        W !!,"Print a structure diagram for a set of routines from an existing summary" S PRT=0
A1      S NAME=0,ALL=1 O 0 U 0 R !!,"Summary name: ",%JB G END:%JB=""!(%JB?1"^".E) G HELP:%JB?1"*".E
        I %JB?1"?".E W !!,"  Enter either a summary name or a '*' to get a list of available summaries" G A1
        I '$D(^UTILITY("SUM1",%JB)) W *7,"  No such summary" G A1
IOD     S IOO=$I,%DEF=$I D ^%IOS G %OVR:'$D(%IOD) S %IO=%IOD G DET:IOO=%IO
USR     O 0 U 0 R !,"User name: ",ARF G IOD:ARF?1"^".E I ARF?1"?".E W "  Enter a name to put on the report header" G USR
HDR     R !,"Do you want a single line (S), full block (F) or no header (N) on listing: <F> ",%HEADER,! I "S,F,N"'[%HEADER W *7,!?4,
"  Please enter either an S, F, N or <CR> for the default",! G HDR
DET     I IOO'=%IO S STR=%JB_" STRUCTURE DIAGRAM FOR "_ARF,%DV=%IO,PRT=1 O %IO U %IO D ^%HDR W #
ALL     O 0 U 0 R !,"All routines? ",X G A2:X?1"Y".E,A1:X?1"^".E I X?1"?".E W "  Enter a Yes or No" G ALL
        S ALL=0
ASK     O 0 U 0 R !!,"Routine: ",NAME G A1:NAME=""!(NAME?1"^".E) I NAME?1"?".E W !,"  Enter a routine name for structure diagram or
an '*' for a list of routines" G ASK
        G A3:$D(^UTILITY("SUM1",%JB,NAME)) I NAME'?1"*".E W *7,"  No such routine" G ASK
        S I=0 W !
ASK1    S I=$N(^UTILITY("SUM1",%JB,I)) G ASK:I<0 W !,I G ASK1
A2      S NAME=$N(^UTILITY("SUM1",%JB,NAME)) I NAME<0 K KO G A1
A3      S NAM=NAME,TAB=18 O %IO U %IO W !!!!,NAM
        K KO,KY,K,Y,G S X=-1,KO(0)=0,O=0,SW=0,K(NAM)="",SWT=1
A4      S X=$N(^UTILITY("SUM1",%JB,NAM,"P",X)) G A4:NAM=X I X<0 W:SWT ! G A6:'SW S SW=SW-1,TAB=TAB-18,X=Y(SW),NAM=KY(SW) S:TAB<18 TA
B=18 G A4
        S Z=^(X),C=0 S:Z["C" C=1 S:Z["O" KO(0)=KO(0)+1,K=KO(0),KO(0,K)=X_"["_C
        S A=-1 F I=0:0 S A=$N(^UTILITY("SUM1",%JB,NAM,"G",A)) G A5:A<0 S B="" S:$D(G(A)) B=G(A) S G(A)=^(A)_B
A5      S:Z["J" C=2 G A4:'C W ?TAB-7,"  " W:C=2 "Starts " W:C'=2 "-----> " W ?TAB,X S SWT=0
        I $D(K(X)) W ! G A4
        S KY(SW)=NAM,NAM=X,K(X)="",Y(SW)=X,X=-1,SW=SW+1,TAB=TAB+18,SWT=1 G A4
A6      G B1:$D(G) S A=-1 F I=0:0:0 S A=$N(^UTILITY("SUM1",%JB,NAM,"G",A)) G B1:A<0 S B="" S:$D(G(A)) B=G(A) S G(A)=^(A)_B
        Q
B1      G B4:'$D(KO(O)),B4:'KO(O) S KO(O)=KO(O)-1,N=$N(KO(O,-1)) G B1:N<0 S Z=KO(O,N),O=O+1,NM=$P(Z,"[",1),C=$P(Z,"[",2),TAB=18,NAM=
NM
        K KO(O-1,N) S X=-1,KO(O)=0,SW=0,SWT=1 K KY,Y G B1:$D(K(NM)) W !,NM S K(NM)=""
B2      S X=$N(^UTILITY("SUM1",%JB,NAM,"P",X)) I X<0 W:SWT ! G B1:'SW S SW=SW-1,TAB=TAB-18,X=Y(SW),NAM=KY(SW) S:TAB<18 TAB=18 G B2
        S Z=^(X),C=0 S:Z["C" C=1 S:Z["O" KO(O)=KO(O)+1,K=KO(O),KO(O,K)=X_"["_C
        S A=-1 F I=0:0 S A=$N(^UTILITY("SUM1",%JB,NAM,"G",A)) G B3:A<0 S B="" S:$D(G(A)) B=G(A) S G(A)=^(A)_B
B3      S:Z["J" C=2 G B2:'C W ?TAB-7,"  " W:C=2 "Starts " W:C'=2 "-----> " W ?TAB,X S SWT=0
        I $D(K(X)) W ! G B2
        S KY(SW)=NAM,NAM=X,K(X)="",Y(SW)=X,X=-1,SW=SW+1,TAB=TAB+18,SWT=1 G B2
B4      I O S O=O-1 G B1
        G:'$D(G) A2:ALL,ASK S TAB=10 W !!,"Globals:" S A=-1 F I=0:0 S A=$N(G(A)) G:A<0 A2:ALL,ASK S D=A W ?TAB,D W:G(A)["S" "*" S TA
B=TAB+10 I TAB>70 S TAB=10 W !
        Q
HELP    S (I,J)=0 W !
H1      S I=$N(^UTILITY("SUM1",I)) I I<0 G A1:J W *7,!?4,"No summaries on file" G A1
        I $D(^UTILITY("SUM1",I,0,0)) W !,I,?10,^(0) S J=1
        G H1
END     I PRT,$D(IOO),$D(%IO),IOO'=%IO U %IO W #### C %IO H
        Q
Z       P %OVR ZS %OVR
