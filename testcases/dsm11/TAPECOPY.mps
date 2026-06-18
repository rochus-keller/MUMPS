TAPECOPY        ;DSM11 Utilities; Copyright 1980 DEC
START   U 0 S $ZE="COPER^TAPECOPY",ST=$V(44),DT=$V(ST+8),(UF,UT)=-1
        C 63 O 63::3 E  G VBUSY
        S ID=^SYS(0,"RUNNING") I ID="" W !,"This utility may not be used in baseline mode",! G DONE
        D SETYP^MMD
ASKF    S (UF,UT)=-1,QUES="FRM",DEF="" X ^%Q("ASK") G:ANS=""!%A DONE
        D TVER G:%FAIL ASKF S UF=ANS+47,UFMOD="BT"
        I RHTYP'[^SYS(ID,"MT",ANS,"TYPE") G TOF
ASKD1   S DEF=800,QUES="DQ" X ^%Q("ASK") G:ANS=""!%A ASKF
        S UFMOD="BT3" G:ANS=800 TOF I ANS'=1600 D DQH G ASKD1
        S UFMOD="BT4"
TOF     S DEF="",QUES="TO" X ^%Q("ASK") G:ANS=""!%A DONE
        D TVER G TOF:%FAIL,SAMER:ANS+47=UF S UT=ANS+47,UTMOD="BT"
        I RHTYP'[^SYS(ID,"MT",ANS,"TYPE") G BLF
ASKD2   S DEF="800",QUES="DQ" X ^%Q("ASK") G:ANS=""!%A TOF
        S UTMOD="BT3" G:ANS=800 BLF I ANS'=1600 D DQH G ASKD2
        S UTMOD="BT4"
BLF     S QUES="ESTQ",DEF=8 X ^%Q("ASK") G:%A ASKF S A=ANS+1
        I ANS'?1N.N!(ANS>99)!(ANS<1) D IV G BLF
TRY     C 63 S SV=$ZE
MXNUM   S A=A-1,$ZE="MXNUM" O 63:A:2 S $ZE=SV E  G MXNUM:A>1,VBUSY
        G OK:A=ANS
        S QUES="LESQ" X ^%Q("ASKY") G BLF:%A,DONE:ANS="N"
OK      S QUES="RDYQ",DEF="" X ^%Q("EN") G:%A DONE I ANS'="" D RDYQH G OK
DOCOP   ;
        O UF:UFMOD:2 E  S ANS=UF-47 D NAVL G START
        O UT:UTMOD:2 E  C UF S ANS=UT-47 D NAVL G START
        S X=UF D INIT G:%FAIL DONE
NEXT    S X=UT D INIT G:%FAIL DONE
        G ONECOP^TAPCOPA
RET     G:%FAIL DONE
        U UF W *5 U UT W *5 U 0
ASKMOR  S QUES="MORQ" X ^%Q("ASKN") G:ANS="N"!%A DONE
MNTNXT  S QUES="MNTOQ",DEF="" X ^%Q("EN") G:%A ASKMOR
        I ANS'="" D MNTOQH G MNTNXT
        G NEXT
DONE    ;
        C:UF>46 UF C:UT>46 UT C 63
        K DT,UF,UT,ANS,%YN,%QMK,%A,%A2,SV,A,DEF,QUES,%FAIL
        K ZB,ZA,TMK,EOT,EOTI,EOTO,TAPMRK,ZE,X
        Q
TVER    S %FAIL=1 I ANS'?1N!(ANS>3) D IV Q
        C ANS+47 S A=$V(DT+47+ANS)#256 G NSUCH:A=255,NAVL:A
        S %FAIL=0 Q
INIT    U X W *5 S %FAIL=1,A=$ZA U 0
        I A\64#2=0 W !,"Magtape Unit# ",X-47," is off-line!",! Q
        I X=UT,A\4#2 W !,"Output Tape is write-locked!",! Q
        S %FAIL=0 Q
VBUSY   W !,"View Buffer busy.",!! G DONE
NSUCH   W !,"** No Magtape Unit# ",ANS," in the running configuration.",!
        Q
NAVL    W !,"** Magtape Unit# ",ANS," is in use by another job.",!
        Q
IV      W !,"Incorrect response -- type '?' for more information.",! Q
SAMER   W !,"** ""FROM"" and ""TO"" units cannot be the same!",!!
        G ASKF
FRM     W !,"Copy *FROM* which Magtape Unit (0, 1, 2, or 3)" Q
TO      W !,"Copy  *TO*  which Magtape Unit                " Q
FRMH    ;
TOH     W !,"Enter the unit # of the magtape drive.",!
        W "Type '^' if you have changed your mind and wish to exit from "
        W "this program.",!! Q
ESTQ    W !,"Estimated maximum blocking-factor ( * 1024 bytes) on input "
        W "tape" Q
ESTQH   W !,"Accept the default value if you are not sure.  If the number "
        W "you input",!
        W "is smaller than (#-of-bytes-in-largest-block divided by 1024), a "
        W "tape error",!
        W "will result.",!! Q
LESQ    W !,"** There are only enough buffers available to handle a blocking "
        W "factor",!
        W "of ",A,".  Okay to proceed assuming ",A," is maximum blocking "
        W "factor ?",!
        W "(Note: If a larger block is encountered, a ""TAPE ERROR"" message "
        W "will be",!
        W "generated) ",! Q
LESQH   W !,"If you are not sure, you may type 'Y' to proceed.  If a block "
        W "is encountered",!
        W "which is too large to fit in the buffers, an error message will be "
        W "generated,",!
        W "and the copy will be stopped.",!! Q
RDYQ    W !,"When the tapes are mounted and ready, please type  <CR> " Q
MNTOQH  ;
RDYQH   W !,"(If you have changed your mind and do not wish to proceed with "
        W "the copy,",!,"type '^' )",! Q
MNTOQ   W !,"Please mount the next output tape on Magtape Unit# ",UT-47,!
        W "  then type  <CR> " Q
MORQ    W !,"Would you like to make another copy of the same tape" Q
COPER   S %ZA=$ZA U 0 I $ZE?1"<INRPT".E W !!,*7,"  Unexpected Interrupt",! G DONE
        W !!,"** ERROR:",!,$ZE,"  $ZA = ",%ZA,!," -- STOPPING.",! G DONE
DQ      W "Density [ 800 or 1600 ] " Q
DQH     W !,"Tapes to be used with TS11/TU80/TS05 drives should be 1600 bpi tapes "
        W "to be",!
        W "used with TM11/TS03 or TU10 or TE10 drives should be 800 bpi.",!!
        W "If the tape is not to be used with either of the above types, it "
        W "may",!
        W "be either density.",! Q
