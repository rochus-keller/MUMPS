DPFORMAT        ;
        U 0 W !!,"To format, test, or initialize a disk, type:",!
        W "D ^DISKPREP",!
QUIT    Q
COPENT  W !,"  ** Begin copy",! S %UPG=0,%FMT=0,%TST=1,%TST(1)="0/0" D GETVARS G NXTP
TAPENT  ;
DISKENT I %UPG S (%B,%TST,%FMT)=0 D GETVARS G NXTP
        D START
NXTP    S $ZT=%LABEL X %LOAD
START   D DUMAPS
ASKFT   I $P(%D," ",6)'="Y" S %FMT=0 G ASKT
ASKF    S QUES="FMTQ" D ASKYN S %FMT=Y
ASKT    S %TST=0,QUES="TSTQ" D ASKYN G:'Y GETVARS S QUES="PATQ" W !
        F P=1+%FMT:1:4 D ASKYN G ASKT:Y="^" S:Y %TST=%TST+1,%TST(%TST)=PT
GETVARS S %DPT=$P(%D," ",8)
        S FMTSIZ=%DPT*$P(%D," ",9)*$P(%D," ",10)
        S %B=0
        S %B=0 I %FMT!%TST V %DT+2::0
        S WSV=$V(ST+70)\256*256
        S UNBRK="B 0 V ST+70::$V(ST+70)#256+256"
        S WFIX="V ST+70::$V(ST+70)#256+WSV B 1"
        S %XTRA=%TY=2!(%TY=3)&%FMT
        C 63 F MXB=127:-5:0 O 63:MXB:0 Q:$T
        S:MXB>65 MXB=65 I MXB'>(2*%DPT) S TRY=MXB G TR
        S TRY=MXB\(%DPT*2)*%DPT*2+%XTRA
TR      F BF=TRY:-2*%DPT:2*%DPT C 63 O 63:BF:2 G GOT:$T
GET     C 63 O 63:BF:2 G GOT:$T S BF=BF+2\2 G GET:BF>2 O 63:2
GOT     K TRY,MXB
DUMAPS  I $E(DDU,1,2)="DU" S $P(%D," ",5)=$V($E(DDU,3)*4+$V(ST+476)+2)#32768*65536+$V($E(DDU,3)*4+$V(ST+476))\800
        Q
ASKYN   D @QUES R " ? [Y/N]  > ",Y,!
AYN2    I "YN"[Y&$L(Y) S Y=$E(Y,1)="Y" Q
        Q:Y="^"&(QUES="PATQ")  D HELP G ASKYN
HELP    S HROU=QUES_"H" D:$L($T(@HROU)) @HROU Q
ASK     W ! D @QUES R " ?  > ",A,! Q:A'="?"  D HELP G ASK
FMTQ    W !,"Do you wish to ""format"" this disk" Q
FMTQH   W !,"Formatting consists of rewriting all infromation on the disk,"
        W "including",!,"special sector-header information used by the "
        W "hardware.  Usually, a pack",!,"That has been formatted once will "
        W "never have to be re-formatted, so you will ",!
        W "usually not format a disk unless it is brand new and you have "
        W "no indication",!,"that it has ever been formatted before.",!
        W "If the disk is already formatted, and you merely wish to test "
        W "it for",!,"bad blocks, answer  'N'  to this question, and  'Y'  "
        W "to the question which",!,"follows it.",! Q
TSTQ    W !,"Do you wish to run a" W:%FMT "n additional" W " comprehensive "
        W "test for bad blocks",!,"on this disk"
        W:%FMT "  (Formatting already includes one such test,",!
        W:%FMT "using the test pattern  177777 octal  (all ones))" Q
PATQH   S P=1+%FMT K %TST S %TST=0
TSTQH   W !,"Each test consists of writing a test pattern on the entire "
        W "disk, then",!,"verifying that it can be read back without "
        W "errors.  Any block which",!,"gives errors (even recoverable "
        W "errors) will automatically be entered",!,"in the bad-block "
        W "table on the disk, and will not be used by DSM11.",!
        W:%FMT "Formatting already includes one such test, using the bit "
        W:%FMT "pattern",!," 177777 octal (all ones)).",!
        W "If you answer 'Y', you will be able to choose, optionally, "
        W "one or more",!,"of the following " W:%FMT "additional " W "test "
        W "patterns:",! W:'%FMT ?20,"177777 octal  (all one bits)",!
        W ?20,"125252 octal  (alternating one and zero bits)",!
        W ?20,"052525 octal  (alternating zero and one bits)",!
        W ?20,"000000 octal  (all zero bits)",!! Q
PATQ    S PT=$P("177777/65535,125252/43690,052525/21845,000000/0",",",P)
        W "Test pattern  ",$P(PT,"/",1)," octal  " Q
