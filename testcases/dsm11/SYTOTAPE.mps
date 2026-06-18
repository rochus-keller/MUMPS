SYTOTAPE        ;DSM11 Utilities; Copyright 1980 DEC
START   U 0 K  S ST=$V(44),DT=$V(ST+8),U=-1
        K ^PATCH S ^PATCH=""
        I '$D(^SYS(0,"PATCH")) G ZT
        S QUES="PATQ" X ^%Q("ASKN") I %A Q
        I ANS'="Y" G ZT
        S G="^SYS(0,""PATCH"")" F I=1:1 S G=$ZO(@G) Q:G'["PATCH"  S @("^PATCH("_$P(G,"(",2))=@G
ZT      S $ZT="ER^SYTOTAPE"
TRY     C 63 O 63::2 E  G VBSY
        W !,"Create a ""DSM-11 Distribution"" magtape from the disk ",!
        W "System Image, Routines and Globals ...",!
ST2     C U S QUES="TAPQ",DEF=0 X ^%Q("ASK") G DONE:%A
        I ANS'?1N!(ANS>3) D IV G ST2
        S AN1=ANS I $V(DT+AN1+47)#256=255 D NCONFIG G ST2
        D SETYP^MMD S ID=^SYS(0,"RUNNING") G ST3:ID=""
ST3     S DEF=800,QUES="DQ" X ^%Q("ASK") G:%A ST2
        S DNS=$S(ANS=800:3,ANS=1600:4,1:"") I DNS="" D IV G ST3
        S U=AN1+47 C U O U:"BT"_DNS:3
        E  W !,"Magtape Unit# ",AN1," is in use by another job.",! G ST2
        U U W *5 S ZA=$ZA U 0
        I ZA\64#2=0 W !,"** TAPE IS OFF-LINE **",! G ST2
        I ZA\4#2 W !,"** TAPE IS WRITE-LOCKED! **",! G ST2
        W !
        U 63:(::"Z"),0 V 0:"S0"
        S ANSTART=$V(497,0)*65536+$V(498,0),ANSIZE=$V(496,0)#256
        S B=1 D BLOCK
        V 2:"S0" U U:(512:512) D MWRT
        F B=3:1:91,ANSTART:1:ANSTART+36 D BLOCK
        V 2:"S0" U U:(512:0) D MWRT
        U U W *3 C U S U=U O U:"CU"_DNS
        S SDP=0 D ROUGLO^V3UTILS
        U U W *5 U 0 W !,"Done"
DONE    C U,63 Q
ER      U 0 I $ZE'?1"<INRPT".E W !,"** ERROR:",!,$ZE,! Q
        W !,*7,"  Unexpected Interrupt",! G DONE
BLOCK   V B:"S0" U U:(512:0) D MWRT U U:(512:512) D MWRT Q
MWRT    W *4 S ZA=$ZA U 0 Q:ZA<128&(ZA>63)
        W !,"! TAPE ERROR !",!,"  $ZA= ",ZA," (DECIMAL),!
        W "  -- STOPPING.",! S $ZE="DONE",=
VBSY    W "  View Buffer busy.",! G DONE
NCONFIG W !,"No Magtape Unit# ",ANS," in the presently running configuration."
        W ! Q
IV      W !,"Incorrect response -- enter '?' for more information.",! Q
PATQ    W !,"Create ^PATCH" Q
PATQH   W !,"Do you wish to copy patches from ^SYS(0,""PATCH"") to another"
        W !,"global called ^PATCH ?  This global will then be copied to"
        W !,"the distribution, and be restored to ^SYS(0,""PATCH"") by the"
        W !,"installation procedure.",! Q
TAPQ    W !,"To which Magtape Unit (0, 1, 2, or 3)" Q
DQ      W !,"Density [ 800 or 1600 ]" Q
DQH     W !,"Enter 800 to write a 800 BPI density tape"
        W !,"Enter 1600 to write a 1600 BPI density tape",! Q
TAPQH   W !,"This program places a bootable copy of the DSM11 V3 System Image "
        W "on a",!
        W "Magtape.  It then follows this with a copy of all the "
        W "system Routines and",!
        W "Globals, making the tape a ""Diskprep"" tape which may then be "
        W "used to create",!
        W "new DSM systems, in exactly the way an original Distribution "
        W "tape would",!
        W "be used.",!!
        W "** Note **",!
        W "  If you have applied any patches using the standard DSM11 V3 "
        W "patch",!
        W "  procedure (the Autopatch ^AUPAT utility), then those patches "
        W "which",!
        W "  you have applied to Disk *will* be in the image that is placed "
        W "on the",!
        W "  tape, while those patches which you have applied to Memory-only "
        W "*will",!
        W "  not* be.",!!
        W "** Note **",!
        W "  Any changes you have made to the system Routines and Globals "
        W "will of",!
        W "  course be reflected on this tape.  This tape should therefore "
        W "*not*",!
        W "  be considered a copy of the DSM11 V3 Distribution Magtape.",!
        W "  To make a copy of the Distribution Magtape, copy the "
        W "Distribution",!
        W "  Magtape using the ^TAPECOPY utility.",!! Q
