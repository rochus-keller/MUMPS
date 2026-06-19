TTTG    ;RLW; TIED TERMINAL TABLE GENERATION
        D ID^SYSROU Q:ID="^"  D START,^MDAT Q
START   S TTTAB=$V(44)+318 D SHO
CON     W !!,"Terminate by responding with <CR> to routine number question"
C       W !!,"Create or edit a table entry:",!
        S (R,V,U,P,NAM)=""
C1      R !,"Routine number > ",R G END:R=""!(R="^")
        I R'?1N!(R<1)!(R>7) D RHLP G C1
        I $D(^SYS(ID,"TIED TERMINAL TABLE",R)) G COD
V       W !,"Volume set number " W:V'="" "<",V R "> ",A G:A="^" C1
        I A="" G:V="" C1 S A=V
        I A'?1"S"1N D VHLP G V
        S V=A
U       W !,"UCI number " W:U'="" "<",U R "> ",A G:A="^" V
        I A="" G:U="" V S A=U
        I A<1!(U>50) D UHLP G U
        S U=A
PAR     I P="" S P=8 I $D(^SYS(ID,"PARTITION","DEFAULT")) S P=^("DEFAULT")\1024
        W !,"Partition size <",P R "> ",A G:A="^" U
        I A="?" D HLP G PAR
        G:A="" D I A<1!(A>16) D IV G PAR
        S P=A
D       W !,"2 character routine name " W:NAM'="" "<",NAM R "> ",A G:A="^" PAR
        I A="" G:NAM="" PAR S A=NAM
        I '($L(A)=2) W "  Name must be 2 characters." G D
        S NAM=A
        S ^SYS(ID,"TIED TERMINAL TABLE",R,"UCI")=U,^("PARTITION SIZE")=P,^("ROUTINE NAME")=NAM,^("VSET")=V G:DMB="D" C
        V TTTAB+(R-1*4)::$E(V,2)*32+U*256+P,TTTAB+(R-1*4)+2::$A(NAM,2)*256+$A(NAM) G C
COD     W !!,"Routine number ",R," already exists"
        R !,"Change or Delete this table entry [C or D] > ",COD
        G C:COD=""!(COD="^") I COD="?" D HLP1 G COD
        I COD="C" S U=^SYS(ID,"TIED TERMINAL TABLE",R,"UCI"),V=^("VSET"),NAM=^("ROUTINE NAME"),P=^("PARTITION SIZE") G V
        I COD'="D" D IV G COD
        S TT="",F=0 F I=0:0 S TT=$O(^SYS(ID,"TTY",TT)) Q:TT=""  I $D(^(TT,"ROUTINE")),^("ROUTINE")=R W !,"TTY ",TT," is currently tied to routine ",R S F=1
        I F W !!,"Unable to delete this table entry",! G C
        K ^SYS(ID,"TIED TERMINAL TABLE",R,"UCI"),^("PARTITION SIZE"),^("ROUTINE NAME"),^("VSET") G:DMB="D" DEL
        V TTTAB+(R-1*4)::0,TTTAB+(R-1*4)+2::0
DEL     W !!,"Routine number ",R," deleted",! G C
END     K N,NAM,RNO,P,R,T,U Q
IV      W !,"Incorrect response - enter '?' for more information" Q
HLP     W !!,"Enter the size of the partition that you want the tied"
        W !,"terminal routine to acquire at login time."
        W !!,"Partitions are specified in 1024 byte increments.  The "
        W !,"minimum partition size is 1 increment and the maximum"
        W !,"is 16 increments.",!,"Enter <CR> to use default partition size.",! q
HLP1    W !!,"Enter ""C"" if you want to change routine number ",R
        W !,"Enter ""D"" if you want to delete routine number ",R Q
RHLP    W !!,"The tied terminal table contains a numeric index to"
        W !,"the routine name that will be called at login.  Enter"
        W !,"a number from 1 to 7.  This number will later be associated"
        W !,"with a DSM-11 routine.",! Q
VHLP    W !!,"Tied terminal routines can allow login into any mounted"
        W !,"Volume Set.  Enter the volume set number that you want"
        W !,"this tied routine to allow login.  Note that set numbers"
        W !,"are in the form, S0, S1, ... so forth.  The system volume"
        W !,"set is always S0.",! Q
UHLP    W !!,"Tied terminal routines can allow login into any available"
        W !,"UCI.  Enter the number of the UCI that you want this tied"
        W !,"routine to allow login into.  If you do not know the UCI,"
        W !,"you may use the ^UCILI utility to list all currently available"
        W !,"UCI's and their numbers.",! Q
SHO     W !!,"******* Tied Terminal Table *******",!!
        I '$D(^SYS(ID,"TIED TERMINAL TABLE")) W !,"** Tied terminal table is empty **" Q
        W !,"Tied terminal table for configuration '",ID,"' :",!
        W !,"ROUTINE #   VOLUME SET  UCI #   PARTITION SIZE   ROUTINE NAME"
        W !,"              NUMBER           (1KB increments)"
        W !,"----------  ----------  -----  ----------------  ------------" S RNO=""
DSP     S RNO=$O(^SYS(ID,"TIED TERMINAL TABLE",RNO)) Q:RNO=""
        W !,?3,$J(RNO,2),?16,^(RNO,"VSET"),?25,$J(^("UCI"),2),?37,$J(^("PARTITION SIZE"),2),?53,^("ROUTINE NAME") G DSP
