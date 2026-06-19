%WU     ;Where used query routine : JEC ; 15-DEC-80  3:31 PM
        R !!,"Routine Breakdown (B), Global References (G), OR Routine References (R): ",X G BRK:X?1"B".E,GBL:X?1"G".E,PGM:X?1"R".E
Q:X=""!(X?1"^".E)
        W !!,"    Enter either a B, G or R" G %WU
BRK     W !!,"Breakdown a routine by Globals/Routines referenced"
A1      R !!,"Summary: ",%JB G %WU:%JB=""!(%JB?1"^".E) I %JB?1"*".E D LIST G A1
        I %JB?1"?".E W !!,"  Enter an existing summary name or a '*' to get a list of existing summaries" G A1
        I '$D(^UTILITY("SUM1",%JB,0,0)) W *7,!?4,"No such summary" G A1
        W "   ",^(0)
A2      R !!,"Routine: ",PGM G A1:PGM=""!(PGM?1"^".E) S X=PGM I PGM?1"*".E D LST G A2
        I PGM?1"?".E W !!,"   Enter either a routine name or a '*' to get a list of routines available" G A2
        I '$D(^UTILITY("SUM1",%JB,PGM)) W *7,"  No such routine" G A2
        S N=0 W !
A3      S N=$N(^UTILITY("SUM1",%JB,X,"P",N)) G A4:N<0 S Y=^(N) W !,N,?12
        F M=1:1:5 S Z=$P("C,O,L,F,J",",",M) S P=Z S:M=5 P="S" W:Y[Z $S(P="C":"Called",P="O":"Overlayed",P="L":"Loaded",P="F":"Filed",P="S":"Started",1:""),"  "
        G A3
A4      S N=0 W !,"Globals used:"
A5      S N=$N(^UTILITY("SUM1",%JB,X,"G",N)) G A2:N<0 W !,N,?12,$S(^(N)="S":"Updates",1:"References") G A5
GBL     ;
        W !!,"Search for all references to a global"
G1      R !!,"Summary: ",%JB G %WU:%JB=""!(%JB?1"^".E) I %JB?1"*".E D LIST G GBL
        I %JB?1"?".E W !!,"  Enter an existing summary name or a '*' to get a list of existing summaries" G G1
        I '$D(^UTILITY("SUM1",%JB)) W *7,"  No such summary" G GBL
G2      R !!,"Global: ",GB,! G G1:GB=""!(GB?1"^".E) S (I,J,N)=0,X=GB G G3:GB?1"*".E
        I GB?1"?".E W !,"   Enter either a global name or a '*' to get a list of globals available" G G2
        G G4
G3      S I=$N(^UTILITY("SUM1",%JB,0,"G",I)) I I<0 G G2:J W *7,"  No globals defined." G G2
        W !,I,?10,^(I) S J=1 G G3
G4      S N=$N(^UTILITY("SUM1",%JB,N)) G G2:N<0,G4:'$D(^UTILITY("SUM1",%JB,N,"G",X))
        W !,N,?12,$S(^(X)="S":"Updates",1:"References") G G4
PGM     ;
        W !!,"Search for all references to a routine"
P1      R !!,"Summary: ",%JB G %WU:%JB=""!(%JB?1"^".E) I %JB?1"*".E D LIST G PGM
        I %JB?1"?".E W !!,"  Enter an existing summary name or a '*' to get a list of existing summaries" G P1
        I '$D(^UTILITY("SUM1",%JB)) W *7,"  No such summary" G PGM
P2      R !!,"Routine: ",PG G P1:PG=""!(PG?1"^".E) S N=0,X=PG I PG?1"*".E D LST G P2
        I PG?1"?".E W !!,"   Enter a routine name" G P2
        W !
P3      S N=$N(^UTILITY("SUM1",%JB,N)) G P2:N<0,P3:'$D(^UTILITY("SUM1",%JB,N,"P",X)) S P=^(X)
        W !,N,?12 W:P["C" "Calls  " W:P["O" "Overlays  " W:P["L" "Loads  " W:P["F" "Files  " W:P["J" "Starts" G P3
LIST    S (I,J)=0 W !
H1      S I=$N(^UTILITY("SUM1",I)) I I<0 Q:J  W *7,!!,?4,"No summaries on file" Q
        I $D(^UTILITY("SUM1",I,0,0)) W !,I,?10,^(0) S J=1
        G H1
LST     W !! S J=0 F I=1:1 S J=$N(^UTILITY("SUM1",%JB,J)) Q:J<0  W ?$X+5,J W:$X>66 !
        W !! Q
Z       P %WU ZS %WU
