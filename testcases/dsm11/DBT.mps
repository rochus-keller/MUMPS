DBT     ; GEF ; DSM UTILITIES ; DISK BLOCK TALLY
FST     S QUES="FAST" X ^%Q("ASKY") G:%A DONE
        I ANS=""!(ANS?1"Y".E) K FST G ^FASTDBT
        I ANS'?1"N".E D IV G FST
        K FST
NRML    O 63::0 E  W !,?5,"View buffer busy, can't proceed." G DONE
        S $ZE="ABO^DBT"
IODEV   K %DEF S %QTY=2 D ^%IOS I '$D(%IOD) G DONE
        D START^%STRTAB S STRN=0 F I=1:1 S STRN=$O(STR(STRN)) Q:STRN=""  I STR(STRN)'="" G STR
        S STRN=0 G INI
STR     S QUES="GETSTR",DEF="" X ^%Q("EN") G:%A FST
        I ANS?1"S"1N,$E(ANS,2)<4 S STRN=$E(ANS,2) G:STR(STRN)="" NOMNT G INI
        I ANS'?3U D IV G STR
        S STRN="" F I=1:1 S STRN=$O(STR(STRN)) Q:STRN=""  I ANS=STR(STRN) G INI
NOMNT   W !,"Volume Set, ",ANS," is not currently mounted",! G STR
INI     K DSK S DSK(0)=0,ST=$V(44),STRTAB=$V(ST+12),STRSIZ=$V(ST+34)#256
        S STOFF=STRSIZ*STRN,UTAB=$V(STOFF+2+STRTAB)
USET    F I=0:20 Q:$V(I,UTAB)=0  S NAM=$V(I,UTAB),U(I\20+1)=$C(NAM\2048#32+64,NAM\64#32+64,NAM\2#32+64)
        S U(0)="???"
ASK     S QUES="GETDSK",DEF="" X ^%Q("EN") G:%A IODEV
        I ANS="" G:DSK(0) T^DBTALLY G IODEV
        I ANS="^A" D ALL G T^DBTALLY
        I ANS'?2U1N D IV G ASK
        S A="" F I=0:0 S A=$O(STR(STRN,A)) Q:A=""  I $P(STR(STRN,A),":")=ANS Q
        I A="" W !,ANS," is not in this volume set, type ? for more help",! G ASK
        S C=DSK(0),C=C+1,DSK(C)=STR(STRN,A),DSK(0)=C
        G ASK
ALL     S A="" F I=0:0 S A=$O(STR(STRN,A)) Q:A=""  S (C,DSK(0))=DSK(0)+1,DSK(C)=STR(STRN,A)
        Q
IV      W !,"Incorrect response - enter '?' for more information.",! Q
NONE    W !,"Not in system or not mounted." Q
ABO     U 0 W !,"** ERROR:  ",$ZE,!
DONE    S $ZT="" C 63 Q
FAST    W !,"Would you like a fast tally" Q
FASTH   W !,"Fast tally gives only totals by map, not by UCI.",! Q
GETSTR  W !,"Enter the Volume Set name to tally" Q
GETSTRH W !,"Enter the 3 character name of the volume set you would like"
        W !,"to tally.  The volume set must be mounted and available to"
        W !,"to the system.",!
        W !,"The following Volume Sets are mounted:",!
        S A="" W ! F I=0:0 S A=$O(STR(A)) Q:A=""  W:$X>70 ! W ?$X+9\10*10,STR(A)
        W ! Q
GETDSK  W !,"Disk" Q
GETDSKH W !!,?5,"Enter mnemonic for disk type and unit"
        W !,?14," (E.G.  'DK0' for RK05 unit 0)"
        W !,?8,"or   <CR>  when done selecting"
        W !,?8,"or    ^A   for all disks in the volume set"
        W !,?8,"or    ^    to terminate without selection",!!
        W !,"The following disks are mounted for Volume Set ",STR(STRN),!!
        S A="" F I=0:0 S A=$O(STR(STRN,A)) Q:A=""  W:$X>70 ! W ?$X+9\10*10,$P(STR(STRN,A),":")
        W ! Q
