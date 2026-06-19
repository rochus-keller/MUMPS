%STRTAB ;STRUCTURE TABLE LOOK UP ROUTINE
        S %QTY=2 K %DEF D ^%IOS G:'$D(%IOD) EXIT
        I "^SC^LP^TRM"'[%DTY!(%DTY="") W !?5,"Improper device selection" U 0 C:%IOD'=$I %IOD G STRTAB
        U %IOD D SHOW
EXIT    U 0 I $D(%IOD) C:%IOD'=$I %IOD
        K %IOD,%QTY,%DTY,%STR Q
START   S S=$S($D(STR)#10:STR,1:"") K STR S STRPNT=$V($V(44)+12),STR=S
        S TYPES="DK,DM,DR,DB,DL,DU"
        F S=0:1:7 D  S STRPNT=$V($V(44)+34)#256+STRPNT
        .I '$V(STRPNT+2) Q
        .S A=$V(STRPNT) I A=0 S STR(S)="" Q
        .S STR(S)=$C(A\2048+64)_$C(A#2048\64+64)_$C(A#64\2+64)
        .S UUS=$S($V(STRPNT+6)>49152:$V(STRPNT+6)-49152,1:1)
        .F UT=1:1:UUS D
        ..S SM=0 I UUS=1 S SM=$V(STRPNT+6)
        ..S EM=$V(3*UT+STRPNT+5)#256+($V(3*UT+STRPNT+6)#256*256)-1
        ..S TYU=$V(3*UT+STRPNT+7)#256\4
        ..S STR(S,UT)=$P(TYPES,",",TYU\8+1)_(TYU#8)_":"_(EM+1)
        K UT,A,S,TYU,STRPNT,SM,EM,UUS Q
SHOW    W !,"DSM-11 Mounted Volume Set Descriptor Table",!
DSPLAY  D START W !?17,"Volume set",?29,"Disk type",?41,"No. of"
        W !?19,"Name",?29,"and unit",?42,"maps",!
        S S="" F I=1:1 S S=$O(STR(S)) Q:S=""  D
        .W !,"Volume Set S",S,?20,STR(S)
        .I STR(S)="" W "no volume set mounted",! Q
        .S UT="" F J=1:1 S UT=$O(STR(S,UT)) Q:UT=""  D
        ..W ?32,$P(STR(S,UT),":",1),?43,$P(STR(S,UT),":",2),!
        Q
MAP     D START
        S STU="" F I=1:1 S STU=$O(STR(STU)) Q:STU=""  S U="",MAP=0 F J=1:1 S U=$O(STR(STU,U)) Q:U=""  G:$P(STR(STU,U),":")=DDU GOTIT S MAP=$P(STR(STU,U),":",2)+MAP
        K STU,MAP G DONE
GOTIT   S STU=STU_","_U
DONE    K STR,U,I,J Q
