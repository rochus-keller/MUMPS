TRANTAB ;16-May-83 ;UTILITIES ;SYSTEM DEFINITION ;DEFINES A TRANSLATION TABLE PART 2 ;JHM
CON     W !!,"Terminate by responding with <CR> to table entry # question:"
        S TABMAX=^SYS(ID,"MEM.ALLOC","TRANSLATION TABLE")-300\14,REPMAX=4
C       R !!,"Table entry # ? > ",T S %A=(T="^") I T=""!%A G DONE
        I T'?.N!(T<1)!(T>TABMAX) W ?25,"Enter an integer between 1 and ",TABMAX," or <CR> to terminate" G C
        S CODE=$V($V(44)+293),COL=$S(CODE#2:"S",1:"N"),CODE=CODE\2#2+7
        S (U,S,G,NU,NS,SC)="" I '$D(^SYS(ID,"TRANSLATION TABLE",T)) G WHICH
CK      W !!,"Table entry #",T," is already defined" R !,"Do you want to change (C) or delete (D) ? > ",COD
        G C:COD=""!(COD="^") I COD="?" D HLP3 G CK
        I COD="C" D  G HD
        .S ENTRY=^SYS(ID,"TRANSLATION TABLE",T),U=$P(ENTRY,";"),S=$P(ENTRY,";",2),G=$P(ENTRY,";",3),NU=$P(ENTRY,";",4),NS=$P(ENTRY,";",5)
        .I $P(ENTRY,";",6)<128 S REP="T",CODE=$P(ENTRY,";",6)\2#2+7,COL=$S($P(ENTRY,";",6)#2:"S",1:"N") Q
        .S REP="R",SC=$P(ENTRY,";",6)-128 Q
        I COD'="D" W !!?5,"Incorrect response, enter '?' for help",! G CK
        K ^SYS(ID,"TRANSLATION TABLE",T) W "   Table entry #",T," deleted" S CHANGE="" G C
WHICH   W !!,"Create Translation entry or Replication entry ? <T> " R REP
        I REP="" S REP="T" G HD
        I REP="?" D REPH G WHICH
        I REP="^" G C
        I REP'="T",REP'="R" W " -- not valid." G WHICH
HD      W !!,"** Enter data for table entry #",T," **",!
D       W !?3,"UCI name ? " W:U'="" "<",U R "> ",A G:A="^" C
        I A="" G:U="" C S A=U
        I A'?3U D HLP1 G D
        S U=A
E       W !?3,"Volume Set name ? " W:S'="" "<",S R "> ",A G:A="^" D
        I A="" G:S="" D S A=S
        I A'?3U D HLP1 G E
        S S=A
F       W !?3,"Global name ? " W:G'="" "<",G R "> ",A G:A="^" E
        I A="" G:G="" E S A=G
        I (A'?1U.UN0.1"*"&(A'?1"%".UN0.1"*"))!($L(A)>8) D HLP2 G F
        S G=A
G       W !?3,$S(REP="R":"Lock Master",1:"New")," UCI name ? " W:NU'="" "<",NU R "> ",A G:A="^" F
        I A="" G:NU="" F S A=NU
        I A'?3U D HLP1 G G
        S NU=A
H       W !?3,$S(REP="R":"Lock Master",1:"New")," Volume Set name ?" W:NS'="" "<",NS R "> ",A G:A="^" G
        I A="" G:NS="" G S A=NS
        I A'?3U D HLP1 G H
        S NS=A
REP     I REP="T" G I
        W !?3,"Replication Schema number ? " W:SC'="" "<",SC R "> ",A G:A="^" H
        I A="" G:SC="" H S A=SC
        I A'?1N!(A<1)!(A>REPMAX) D SCH G REP
        S SC=A G SET
I       W !?3,"Enter global encoding [8 = 8-BIT, 7 = 7-BIT] <",CODE R "> ",A G:A="^" H
        G:A="" J I A'=7,A'=8 D ENCH G I
        S CODE=A
J       W !?3,"Enter global collating [S = STRING, N = NUMERIC] <",COL R "> ",A G:A="^" I
        G:A="" SET I A'="S",A'="N" D COLH G J
        S COL=A
SET     S ^SYS(ID,"TRANSLATION TABLE",T)=U_";"_S_";"_G_";"_NU_";"_NS_";"_$S(REP="T":CODE=8*2+(COL="S"),1:SC+128),CHANGE="" G C
DONE    Q
HLP     W !!?5,"Enter ""Y"" to set up UCI translation table, if you want to"
        W !?5,"provide a system-level mapping of globals to UCI nodes."
        W !?5,"Enter ""N"" or <CR> if you do not wish to include this UCI capability." Q
HLP1    W !!?5,"Enter 3 alphabetic chars. name, please!",! Q
HLP2    W !!?5,"Enter a valid global name (1 to 8 chars.), please!"
        W !?5,"You may terminate the name with ""*"" for generic translation"
        W !?5,"of all globals starting with the preceding characters.",! Q
HLP3    W !!?5,"Enter ""C"" if you want to change table entry #",T
        W !?5,"Enter ""D"" if you want to delete table entry #",T Q
ENCH    D FORMH W !,"Enter 8 if the global is 8-bit encoded."
        W !,"Enter 7 if the global is 7-bit encoded."
        W !,"Press return to select the displayed default.",! Q
COLH    D FORMH W !,"Enter ""S"" if the global is STRING collated."
        W !,"Enter ""N"" if the global is NUMERIC collated."
        W !,"Press return to select the displayed default.",! Q
FORMH   W !!,"UCI translation requires that the translation table entry"
        W !,"contains the encoding and collating information about the "
        W !,"on-disk structure of the target global.  Usually this encoding"
        W !,"and collating will be identical to the system-wide default"
        W !,"schemes selected during SYSGEN.  If not, you must modify this"
        W !,"information to correspond to the proper disk format for the"
        W !,"translated global.  In cases where this information is incorrect,"
        W !,"DSM will return a <FORMT> error indicating an incorrect format"
        W !,"was specified.",! Q
REPH    W !!,"Replication entries cause Set and Kill operations to be repeated"
        W !,"in other UCIs.  Use this utility to specify which globals to replicate,"
        W !,"and use ^REPTAB to specify a list of UCIs where globals are to be replicated."
        W !!,"Translation is a means to make DSM automatically set a global"
        W !,"in another UCI and Volume Set without using extended syntax.",!! Q
SCH     W !!,"Specify one the ",REPMAX," replication schemas that you created with ^REPTAB." Q
