%GLOMAN ;27-Feb-84 ;UTILITY ;GLOBAL MANAGEMENT ;ALLOWS GLOBAL PLACEMENT AND CHANGE CHARACTERISTICS ;JHM
START   W !!,"Global Management Utility",!
        C 63 O 63::0 E  W !,"View buffer is busy - unable to proceed",! G EXIT
        K  S $ZT="%PROT^%GLOMAN" D START^%STRTAB
        I $ZU("")'="1,0" S %SYS=$P($ZU(0),",",2),%UCI=$P($ZU(0),","),STRNO="S"_$P($ZU(""),",",2),UCINUM=+$ZU("") G GETGLO
        S %SYS=STR(0) S A=$O(STR(0)) G:A="" GETUCI G:STR(A)="" GETUCI
GETVOL  S DEF="" S:$D(%SYS) DEF=%SYS
        S QUES="VOLSET" X ^%Q("EN") G:ANS=""!%A EXIT
        I ANS'?3U D IV G GETVOL
        S %SYS=ANS
GETUCI  S DEF="" S:$D(%UCI) DEF=%UCI
        S QUES="UCINAM" X ^%Q("EN") G:ANS=""!%A EXIT
        I ANS'?3U D IV G GETUCI
        S %UCI=ANS D CHKSYS^%GLO1 I %A K %SYS,%UCI G GETVOL
        S UCINUM=+UCN,STRNO="S"_$P(UCN,",",2)
GETGLO  W !,"Global > ^" R ANS,! G:ANS=""!(ANS="^") EXIT
        I ANS="?" D NAMEH G GETGLO
        I ANS'?1"%"0.7AN,ANS'?1A0.7AN D IV G GETGLO
        S GLON=ANS D GETDIR^%GLO1 G:%A EXIT
        S %BN=$V(UCB+10,UCIMM)*400 D BLNUM^%GLO1 S DF("DGD")=%BN1
        S %BN=$V(UCB+12,UCIMM)*400 D BLNUM^%GLO1 S DF("DGP")=%BN1
        W !,"^",GLON," is currently ",$S('DF:"not ",1:""),"defined",!
        I DF'=0 D MENU^%GLO2 G GETGLO
ASKPLC  S QUES="PLACE" X ^%Q("ASKY") G:ANS="N"!%A GETGLO
GPTR    S DEF=DF("DGP"),QUES="PTR" X ^%Q("EN") G:%A ASKPLC
        S %BN1=ANS D MAPCHK^%GLO1 G:%A GPTR
        S DF("NGP")=%BN1
GDAT    S DEF=DF("DGD"),QUES="DATA" X ^%Q("EN") G:%A GPTR
        S %BN1=ANS D MAPCHK^%GLO1 G:%A GDAT
        S DF("NGD")=%BN1
        D SETDIR^%GLO1 G:%A GETGLO
        W !,"^",GLON," placed" D GETDIR^%GLO1 B:'DF
        D START^%GLO2 G GETGLO
EXIT    K  C 63 Q
%PROT   U 0 W !,"Error: ",$ZE,! C 63 Q
IV      W !,"Invalid response - Type ? for Help",! Q
VOLSET  W !,"Volume Set" Q
VOLSETH W !,"Enter the Volume Set name which contains the global that"
        W !,"you wish to manage."
        W !!,"Volume set names must contain 3 upper case alphabetic characters.",! Q
UCINAM  W !,"UCI" Q
UCINAMH W !,"Enter the name of the UCI which contains the global that"
        W !,"you wish to manage."
        W !!,"UCI names must contain 3 upper case alphabetic characters.",! Q
PLACE   W !,"Do you wish to create and place ^",GLON Q
PLACEH  W !,"Answer ""Y"" if you wish to create global, ^",GLON," and"
        W !,"place it in volume set ",%SYS,!
        Q
PTR     W !,"Address of the 1st GLOBAL POINTER BLOCK" Q
PTRH    W !,"Enter the DISK and MAP number for the first GLOBAL POINTER BLOCK"
        W !,"to be allocated.  Subsequent allocations of pointer blocks"
        W !,"will be made beyond this address.",! D DATFRM Q
DATA    W !,"Address of the 1st GLOBAL DATA BLOCK" Q
DATAH   W !,"Enter the DISK and MAP number for the first GLOBAL DATA BLOCK"
        W !,"to be allocated.  Subsequent allocations of data blocks"
        W !,"will be made beyond this address.",! D DATFRM Q
DATFRM  W !,"Use the form: DDU:MAP:BLK where:",!
        W !?3,"DDU is the disk and Unit (ex. DK0, DU1)"
        W !?3,"MAP is the map number on DDU"
        W !?3,"BLOCK within map must always be 0",!
        Q
NAMEH   W !!,"Enter a global name from 1 to 8 characters long.",!
        W !,"If the global is not defined, you will be allowed to"
        W !,"specify disk growth areas and create the directory node."
        W !!,"If the global is defined, you will be allowed to alter"
        W !,"the global's characteristics.",! Q
