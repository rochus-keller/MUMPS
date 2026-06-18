DGAM    ; GEF ; DSM UTILITIES ; DISK GROWTH AREA MANAGEMENT
        O 63::0 E  W !,?5,"View buffer busy" Q
        D QUIET^SYSWAIT G:%FAIL ERROR
START   W !!,"UCI Growth Area Management",!
        D START^%STRTAB S NXSTR=0,ST=$V(44),P8=256,P16=65536,P18=262144,P21=2097152
        F I=0:0 S NXSTR=$O(STR(NXSTR)) Q:NXSTR=""  I STR(NXSTR)'="" G RD
        S STRNO="S0" G ST
RD      R !,"Which volume set ? > ",STRNO,!
        I STRNO=""!(STRNO="^") G DONE
        I STRNO'?1"S"1N&(STRNO'?3AN) D HLP G RD
        S NXSTR="" F I=1:1 S NXSTR=$O(STR(NXSTR)) Q:NXSTR=""  I STRNO=("S"_NXSTR)!(STRNO=STR(NXSTR)) G MNT
        W !!,"Volume Set ",STRNO," not in system",! G RD
MNT     I STR(NXSTR)="" W !!,"There is no disk mounted in structure ",STRNO,".",!
        I  W "Type ""D ^MOUNT"" to mount the structure.",! G DONE
ST      S ST=$V(44),STRTAB=$V(ST+12),STRSIZ=$V(ST+34)#256
        S:STRNO?3AN STRNO="S"_NXSTR S UTAB=$V(STRSIZ*$E(STRNO,2)+2+STRTAB)
        S SYS=STR($E(STRNO,2))
        U 63:(::"Z"),0 V 0:STRNO U 63:(::"C"),0 S UCIBLK=$V(512+400,0)#256*65536+$V(512+398,0)
        V UCIBLK:STRNO S UCINO=1
GETU    S UCIOFF=UCINO-1*20 S U=$V(UCIOFF,0) G:'U UCI
        S UNM(UCINO)=$C(U\2048+64)_$C(U#2048\64+64)_$C(U#64\2+64) S UCINO=UCINO+1 G GETU
UCI     R !,"Which UCI ? > ",X I X=""!(X="^") G DONE
        I X="^L" D LIST G UCI
        I X="?" D UCHLP G UCI
        I X'?3A D IV G UCI
        S I=-1 F K=1:1 S I=$N(UNM(I)) Q:I<0  I UNM(I)=X Q
        I I<0 W !?5,"UCI, ",X," is not defined in volume set ",STRNO,! G UCI
        S UCI=X,UCB=I-1*20 W ! G 1
OPT     W ! F OPT=1:1:$P($T(OPTAB),";;",2) W !?2,OPT,") ",$P($T(OPTAB+OPT),";;",2)
        W !!,"Select option number > " R X,!
        G:X="" DONE G:X="^" START
        I X="?" W !,?5,"ENTER A SELECTION FROM 1 TO ",$P($T(OPTAB),";;",2),!! G OPT
        I X'?1N!(X<1)!(X>$P($T(OPTAB),";;",2)) D IV G OPT
        S OPT=X G @OPT
1       V UCIBLK:STRNO S A("SNRG")=$V(UCB+8,0)*400,A("SNGD")=$V(UCB+10,0)*400
        S A("SNGP")=$V(UCB+12,0)*400,A("TOP")=$V(UCB+14,0)*400
        W !?2,"New Routines       New Globals       New Globals     Maximum UCI"
        W !?2,"Growth Area      Ptr. Growth Area  Data Growth Area     Extent"
        W !?2,"------------     ----------------  ----------------   ----------",!
        W !?2 S X=A("SNRG") D CON W X,?22 S X=A("SNGP") D CON W X,?42 S X=A("SNGD") D CON W X S X=A("TOP") D CON W ?58,X,! G OPT
2       ;
3       ;
4       ;
5       S QRY="NEW "_$P($T(OPTAB+OPT),";;",3)_" GROWTH AREA ? < "
        S OFF=$P($T(OPTAB+OPT),";;",4)
        S X=$V(UCB+OFF,UTAB)*400 D CON S OV=X
A2      W !,QRY,OV," > " R X I X=""!(X="^") G OPT
        I X'?2U1N1":"1N.N.":"."0" W !!,"Enter the disk unit and map in the form DDU:MAP:BLK#",!!,"BLK# must be 0 or null",! G A2
        F I=1:1:3 S X(I)=$P(X,":",I)
        I X(3)="" S X(3)=0
        S MAPS=0,K=1,STRNR=$E(STRNO,2)
N2      I '$D(STR(STRNR,K)) W !!,X(1)," is not part of this volume set",!! G A2
        S %M=$P(STR(STRNR,K),":",2)
        I X(1)'=$P(STR(STRNR,K),":",1) S MAPS=MAPS+%M,K=K+1 G N2
        I X(2)+1>%M W !!,X(1)," has only ",%M," maps, numbered 0 to ",%M-1,!! G A2
        S X=400*MAPS+(400*X(2))+X(3),CK=1
        V UCIBLK:STRNO
        V UCB+OFF:UTAB:X\400,UCB+OFF:0:X\400,-UCIBLK:STRNO
        S DEF=X D CON I X'=OV W "  -  UCI table modified"
        G OPT
LIST    S I=-1 W !
L1      S I=$N(UNM(I)) I I<0 W ! Q
        W "# ",I," = ",UNM(I),! G L1
CON     S K=1,STRNR=$E(STRNO,2) I X=0 S X="NONE" Q
N1      S STRVOL=STR(STRNR,K),MAPS=$P(STRVOL,":",2)
        I X'<(400*MAPS) S K=K+1,X=X-(400*MAPS) G N1
        S X=$P(STRVOL,":",1)_":"_(X\400)_":"_(X#400) Q
ERROR   I %FAIL>1 W !,*7,"SYSTEM STILL ACTIVE",!,*7
        C 63 D RELSYS^SYSWAIT K  Q
DONE    D ZGLAST^%SYSROU V ST::%STSAV C 63 D RELSYS^SYSWAIT B 1 K  Q
HLP     W !!,"Enter   a valid structure number (ex. S0) or structure name (ex. SYS)"
        W !?8,"in the configuration you are currently running for which"
        W !?8,"you want to run the disk growth area management utility",!! Q
UCHLP   W !?5,"Enter the three character UCI name of the UCI for which"
        W !?5,"growth area pointers are to be modified."
        W !!?5,"Enter ^L to list all the UCI's for the selected volume set.",! Q
IV      W !,?5,"INCORRECT RESPONSE - ENTER '?' FOR MORE INFORMATION" Q
OPTAB   ;;5
        ;;Show current Defaults
        ;;Modify ROUTINE GROWTH AREA;;ROUTINES;;8
        ;;Modify GLOBAL POINTER GROWTH AREA;;GLOBALS POINTER;;12
        ;;Modify GLOBAL DATA GROWTH AREA;;GLOBALS DATA;;10
        ;;Modify UCI maximum DATA and ROUTINE GROWTH AREA;;UCI MAXIMUM;;14
