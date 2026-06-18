TRANTAB ;16-May-83 ;UTILITIES ;SYSTEM DEFINITION ;DEFINES A TRANSLATION TABLE ;JHM
EDIT    D ID^SYSROU Q:ID="^"  I ^SYS(ID,"OPTIONS","TRANTAB")="Y" K CHANGE D UCITAB D:$D(CHANGE) ^MDAT Q
        W !,"UCI Translation Table support was not included in the ",ID," configuration",! Q
DISAB   D CHECK Q:%A
        V 0:$V(ST+276):0 W !,"UCI translation disabled",! Q
ENAB    D CHECK Q:%A
        D VIEW W !,"UCI translation enabled" Q
SHOW    D CHECK Q:%A  D SHOTAB Q
UCITAB  D SHOTAB G CON:%A
EDI     R !,"Do you want to edit this table ? [Y/N] > ",A G DONE:A="^",DONE:A="N"
        I A'="Y" W !,"If you would like to add, delete, or edit entries type Y",! G EDI
CON     K CHANGE D ^TRANTB1 G:%A EDI I '$D(CHANGE) G DONE
        S NXT="" F I=1:1 S NXT=$O(^SYS(ID,"TRANSLATION TABLE",NXT)) Q:NXT=""  S ^(I)=^(NXT) K:NXT'=I ^(NXT)
        K UCIFL,OPT,ENTRY,UCIDA,T,U,S,G,NU,NS,COD
        Q:DMB="D"  D VIEW
        G DONE
ZERO    F I=0:2:254 V I:M:0
DONE    K NXT,ADDR,UCIDA,NAM,SNAM Q
UPDTAB  S ID=^SYS(0,"RUNNING")
VIEW    S ST=$V(44),M=$V(ST+276) I M=0 Q
        I $O(^SYS(ID,"TRANSLATION TABLE",""))="" G ZERO
        W !!,"Reloading the UCI TRANSLATION TABLE",!
        S ONEJOB=$V(ST+75)!$V(ST+35),$ZT="VDON"
        I 'ONEJOB D QUIET^SYSWAIT G:%FAIL=-1 VDON
        F I=0:2:254 V I:M:0
        S NXT="" K TT F I=0:1 S NXT=$O(^SYS(ID,"TRANSLATION TABLE",NXT)) Q:NXT=""  S E=^(NXT) D
        .S UC=$P(E,";"),SY=$P(E,";",2) D GETUCN I 'UCN K SNAM D:BD NOUCI Q
        .S N=$P(E,";",3) I $P(N,"*")'=N S N=$P(N,"*")_$C(126)
        .S TT(W1,N)=$P(E,";",4,6)
        S UCT=0,ADDR=256
        F I=0:1 S UCT=$O(TT(UCT)) Q:UCT=""  S ADDR=ADDR#4+ADDR D
        .V UCT\2*2:M:ADDR-252\4*(UCT#2*255+1)+$V(UCT\2*2,M)
        .S NAM="" F I=0:1 S NAM=$O(TT(UCT,NAM)) Q:NAM=""  D
        ..S UCIDA=TT(UCT,NAM),SNAM=NAM
        ..I SNAM'[$C(126),$L(SNAM)=8 S SNAM=SNAM_$C(255) G STORE
        ..I SNAM[$C(126) S SNAM=$P(SNAM,$C(126))_$C(255)
        ..E  S SNAM=SNAM_$C(0)_$C(255)
STORE   ..F I=1:2:$L(SNAM) V:I<$L(SNAM) ADDR+(I-1):M:$A(SNAM,I+1)*256+$A(SNAM,I) V:I=$L(SNAM) ADDR+(I-1):M:$A(SNAM,I)
        ..S:I#2 I=I+1 F K=I:2:6 V ADDR+K:M:0
        ..V ADDR+8:M:$P(UCIDA,";",3)*256+($V(ADDR+8,M)#256)
        ..S UC=$P(UCIDA,";"),SY=$P(UCIDA,";",2) D GETUCN I BD D NOUCI Q
        ..V ADDR+10:M:W1,ADDR+12:M:W2
        ..S ADDR=ADDR+14
        .V ADDR:M:0 S ADDR=ADDR+2
VDON    I 'ONEJOB D RELSYS^SYSWAIT
        K ONEJOB,ADDR,UC,SY,NXT,UCIDA,BD,M,UCT,SNAM
        Q
NOUCI   W !,"Uci ",UC,", in Volume Set ",SY," does not exist"
        I '$D(SNAM) W ", entries ignored.",! Q
        W !,"Translation Table entry #",NXT," for ^",SNAM,", has been ignored",!
        Q
CHECK   S ID=^SYS(0,"RUNNING"),%A=ID="",ST=$V(44)
        I %A W !,"UCI translation is not available in baseline mode" Q
        S %A=^SYS(ID,"OPTIONS","TRANTAB")="N"
        I %A W !,"UCI translation is not available on the current configuration"
        Q
SHOTAB  S %A=$O(^SYS(ID,"TRANSLATION TABLE",""))="" I %A W !,"** UCI translation table for configuration """,ID,""" is empty **" Q
        W !,"UCI translation table for configuration """,ID,""" :",!
        S ENTRY="" W !,"Entry #",?9,"UCI",?14,"Vol Set",?23,"Global Name",?36,"New UCI",?45,"New Vol",?54,"Collating",?65,"Encoding"
,?75,"Rep."
        W !,?14,"name",?36,"name",?45,"Set name",?74,"Schema",! D LIN
DSP     W ! S ENTRY=$O(^SYS(ID,"TRANSLATION TABLE",ENTRY))
        I ENTRY="" W ! D LIN Q
        S UCIDA=^(ENTRY)
        W !,$J(ENTRY,2),?9,$P(UCIDA,";",1),?16,$P(UCIDA,";",2),?25,$J($P(UCIDA,";",3),8)
        W ?38,$P(UCIDA,";",4),?47,$P(UCIDA,";",5)
        I $P(UCIDA,";",6)>128 W ?76,$P(UCIDA,";",6)-128 G DSP
        W ?55,$S($P(UCIDA,";",6)#2:"String",1:"Numeric")
        W ?66,$S($P(UCIDA,";",6)\2#2:8,1:7),"-Bit"
        G DSP
GETUCN  S BD=0,$ZT="NOTDEF",UCN=$ZU(UC,SY),W1=$P(UCN,",",2)*32+$P(UCN,",",1),W2=0 Q
NOTDEF  I $ZE'["NOSYS",$ZE'["NOUCI" ZQ
        S UCN=0 I $ZE["NOSYS" D
        .S W1=$A(UC)-64*1024+($A(UC,2)-64*32)+$A(UC,3)-64*2
        .S W2=$A(SY)-64*1024+($A(SY,2)-64*32)+$A(SY,3)-64*2
        E  S BD=1
        Q
LIN     F I=1:1:78 W "-"
        Q
HLP     W !!?5,"Enter ""Y"" to set up UCI translation table, if you want to"
        W !?5,"provide a system-level mapping of globals to UCI nodes."
        W !?5,"Enter ""N"" or <CR> if you do not wish to include this UCI capability." Q
HLP1    W !!?5,"Enter 3 alphabetic chars. name, please!",! Q
HLP2    W !!?5,"Enter a valid global name (1 to 8 chars.), please!"
        W !?5,"You may terminate the name with ""*"" for generic translation"
        W !?5,"of all globals starting with the preceding characters.",! Q
HLP3    W !!?5,"Enter ""C"" if you want to change table entry #",T
        W !?5,"Enter ""D"" if you want to delete table entry #",T Q
Z       ZP TRANTAB ZS TRANTAB Q
