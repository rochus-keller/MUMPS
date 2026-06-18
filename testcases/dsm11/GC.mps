GC      ;22-Jul-83 ;UTILTIY ;GLOBALS ;COPIES GLOBALS ACROSS SYSTEM AND UCI'S ;JHM
%START  S $ZT="%ERR^GC"
        W !,"Global Copy",!
        I $ZU("")'="1,0" W !,"Global copy must be run from the System Manager's account",! G %Q
Q1      S DEF=$P($ZU(0),",",2),QUES="SYS" X ^%Q("EN") G:%A %Q
        I ANS'?3U D IV G Q1
        S SYS=ANS
Q2      S DEF="",QUES="UCI" X ^%Q("EN") G:%A Q1 G:ANS="" Q1
        I ANS'?3U D IV G Q2
        S UCI=ANS
        D GETUCN G:'UCN Q1
        S %PGC="",%UCIN=UCN#64,%SN=UCN\64,FUCI=UCI,FSYS=SYS
Q3      S DEF=$P($ZU(0),",",2),QUES="SYST" X ^%Q("EN") G:%A Q2
        I ANS'?3U D IV G Q3
        S SYS=ANS
Q4      S DEF="",QUES="UCIT" X ^%Q("EN") G:%A Q3 G:ANS="" Q3
        I ANS'?3U D IV G Q4
        S UCI=ANS,TUCI=UCI,TSYS=SYS
%WRTE   W !,"Copy globals from ",FUCI,",",FSYS," to ",TUCI,",",TSYS,!
%ASKL   S QUES="LIST" X ^%Q("ASKN") G:%A Q2 S %LIST=ANS="Y"
%DO     D START^GC1
%Q      K %,%N
%KL     K UCI,SYS,%N,%PGC,%UCIN,%UCIT,%UCIF,%FLG,%ST,%UCI Q
%ERR    I $ZE?1"<PROT".E W !,"Global ^",GL," is protected from being copied",! G %START
        I $ZE["<INRPT" W !,"Copy aborted" G %Q
        U 0 W !,"Error detected: ",$ZE Q
LIST    W !,"List global nodes during copy" Q
LISTH   W !,"Type Y if you want to list every global node and data"
        W !,"record being copied.",! Q
SYS     W !,"Copy global FROM Volume Set" Q
SYSH    W !,"Enter the 3 character Volume Set name which contains"
        W !,"the global that you wish to copy.  Type RETURN to take"
        W !,"the default.",! Q
UCI     W !,"Copy global FROM UCI" Q
UCIH    W !,"Enter the 3 character UCI name which contains the global"
        W !,"that you wish to copy.  You may not copy a global from "
        W !,"your current UCI.",! Q
SYST    W !,"Copy global TO Volume Set" Q
SYSTH   W !,"Enter the 3 character Volume Set name that will receive"
        W !,"that global that you wish to copy.  Type RETURN to take"
        W !,"the default.",! Q
UCIT    W !,"Copy global TO UCI" Q
UCITH   W !,"Enter the 3 character UCI name which will receive the"
        W !,"global you wish to copy.  You may not copy a global from "
        W !,"your current UCI.",! Q
IV      W !,"Invalid response - type ? for help",! Q
GETUCN  S $ZT="CHKUCI",UCN=$ZU(UCI,SYS),UCN=$P(UCN,",",2)*64+UCN
        Q
CHKUCI  I $ZE["<NOUCI" W !,"The UCI"
        E  I $ZE["<NOSYS" W !,"The VOLUME SET name"
        E  W !,$ZE ZQ
        W " specified is not in the current configuration"
        W !,"This operation can not be completed.",! S UCN=0 Q
