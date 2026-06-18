BLDMP   ;22-AUG-78;DUMP DISK BLOCKS ;UPDATED FOR V2 -FDN
        S BYTES=0
A       U 0 S ZTRAP=$ZT,$ZT="ERROR^BLDMP" I $D(%IOD) C:'(%IOD=$I) %IOD
DEV     U 0 S %QTY=2,DEF=0 D ^%IOS I '$D(%IOD) G EXIT
BLOCK   D TYPES^SYSROU U 0 R !,"Block # > ",BLN G:BLN=""!(BLN="^") A
        I BLN?1N.N1":"1"S"1N S ARG1=$P(BLN,":",1),ARG2=$P(BLN,":",2) G TST
        I BLN?1N.N1":"1"D"1A1N S ARG1=$P(BLN,":",1),ARG2=$P(BLN,":",2) G:TYPES[$E(ARG2,1,2) TST G BQ
        G:BLN'?1N.N BQ S ARG1=BLN#262144,ARG2=$P(TYPES,",",BLN\2097152+1)_(BLN\262144#8)
TST     D START^%STRTAB S STRNR=""
        F I=1:1 S STRNR=$O(STR(STRNR)) Q:STRNR=""  S NXVOL="" F J=1:1 S NXVOL=$O(STR(STRNR,NXVOL)) Q:NXVOL=""  G:$E(ARG2,2)=STRNR ST
 I $P(STR(STRNR,NXVOL),":",1)=ARG2 G ST
        I ARG2?1"D".E S STRNR="?" G ST
        D IV G BLOCK
ST      S STRNR="S"_STRNR,MBLN=ARG1\400*400+399
        D O63 G:O63 EXIT G:ARG1 VW
PHY     U 0 W !,"Physical or Logical block 0 [P/L] ? > " R PHY I PHY=""!(PHY="^") G ST
        I PHY="?" W !,"Type P to dump the label block, Type L to dump the remapped block 0",! G PHY
        I "PL"'[PHY D IV G PHY
VW      V MBLN:ARG2 I '($V(1006,0)=65535)!'($V(1012,0)=32769) W " (map block for this block isn't valid) ",! S AREA="none" G TYPE
        S AREA="G" I $V(1008,0)=56173&($V(1010,0)=56173) S AREA="Spool"
        I $V(1008,0)=43690&($V(1010,0)=21845) S AREA="SDP"
        I $V(1008,0)=13107&($V(1010,0)=52428) S AREA="Journal"
TYPE    C 63 U 0 R !,"Additional octal dump <N> ",YN S:YN="" YN="N"
        I YN=$E("NO",1,$L(YN)) S YN="N" G OPEN^BLDMP1
        I YN'=$E("YES",1,$L(YN)) G TQ:YN="?",BLOCK:YN="^" D IV G TYPE
        S YN="Y" G OPEN^BLDMP1
EIGHTB  F I=1:1:LSUB S TERM=1,P=P+1,C=$V(P,0)#256 S:'C TERM=0 S COM=COM_$C(C)_TERM
        F I=1:2 S C=$A($E(COM,I)),SUB=SUB_$C(C\2) Q:'(C#2)
        Q:I'<($L(COM)-1)  S SUB=SUB_D,D=","
G1      S I=I+2,C=$A($E(COM,I)),NEGSUB=0 I (C'<2)&(C'>127) S NEGSUB=1,SUB=SUB_"-"
G2      S I=I+2 I NEGSUB I $A($E(COM,I))=254 S I=I+2
        I I'<($L(COM)-1) S SUB=SUB_")" Q
        I '$E(COM,I+1) S SUB=SUB_D G G1
        I 'NEGSUB!($E(COM,I)=".") S SUB=SUB_$E(COM,I) G G2
        S SUB=SUB_(9-$E(COM,I)) G G2
ERROR   C 63 S ZE=$ZE,$ZT="ERROR^BLDMP" U 0
        W !,"Error: $ZE=",ZE,! D ERROR1 G BLOCK
ERROR1  I $D(%IOD) I %IOD'=$I U %IOD W !!,"Error: $ZE=",ZE,!
        Q
IV      W !?5,"Incorrect response - Enter '?' for more information." Q
BQ      W !!,"Enter a block # in one of the following formats:"
        W !,"1. A logical block # followed by disk type and unit (ex. 123:DL0)"
        W !,"2. A logical block # followed by structure number (ex. 123:S0)"
        W !,"3. An V1-V2 format DSM block number (Type*2097152+(Unit*262144)+Logical block #)"
        W !!,"Enter <CR> or ^ to quit.",!
        G BLOCK
TQ      W !?5,"Enter 'Y' to print symbolic and octal dump"
        W !?8,"or 'N' or <CR> to ignore octal dump." G TYPE
O63     S O63=0 O 63::0 Q:$T  W !?5,*7,"View Buffer busy"
        R !,"Try again <N>",YN S:YN="" YN="N"
        G:$E(YN,1)="Y" O63 S O63=1 Q
EXIT    C 63 S $ZT=ZTRAP U 0 I $D(%IOD) C:%IOD'=$I %IOD
        K %DTY,%DO,%IOD,A,ANS,AREA,BN,BTYP,BLOFF,BLN,C,CNT,COM,D,DATA,DEF,DL,HOLD,I,L,LSUB,MBLN,NAM,NXTBL,O63,P,PB,REF,SUB,UTLB,X,YI
,YN Q
BYTE    S BYTES=1 G A
        -
