MBP1    ;PART 2 OF MBP, DUE TO PROGRAM OVERFLOW; 24-NOV-80
        Q
START   W:SGN !,"PART 12:",?10,"BASIC SYSTEM PARAMETERS",!,"--------",!
UDA     S DEF="NONE",QUES="UDAQ" X:EXTH ^%Q("EXTH")
        S UDA=0 I SOFT S ANS=DEF,FEAT="UDA disks that are dual-ported." D SHOUDA G SETUDA
        I $D(^SYS(ID,"MISCELLANEOUS","UDA DUAL-PORTED UNITS")) S DEF=^("UDA DUAL-PORTED UNITS")
        X ^%Q("SGEN") G:%A RETURN S UDA=0 I ANS="NONE" G SETUDA
        F I=1:2:$L(ANS) D
        .S U=$E(ANS,I) I U'?1N!(U>7) G ER
        .S X=1 F J=1:1:U S X=X+X
        .S UDA=UDA#X+X+(UDA\(X*2)*(X*2))
        .S U=$E(ANS,I+1) I U=""!(U=",") Q
ER      .S %A=1 Q
        I %A=1 D IV G UDA
SETUDA  I DMB'="D" V ST+40::$V(ST+41)*256+UDA
        I DMB'="M" S ^SYS(ID,"MISCELLANEOUS","UDA DUAL-PORTED UNITS")=ANS,^("UDA BITS")=UDA
VIEW    S DEF="Y",QUES="VPROT" X:EXTH ^%Q("EXTH")
        I SOFT S ANS=DEF,FEAT="View buffer device protection" D FEAT G SETV
        I $D(^SYS(ID,"MISCELLANEOUS","VIEW RESTRICTION")) S DEF=^("VIEW RESTRICTION")
        X ^%Q("SGASKYN") G:%A UDA
SETV    I DMB'="D" V ST+310::$V(ST+310)-($V(ST+310)#2)+(ANS="Y")
        I DMB'="M" S ^SYS(ID,"MISCELLANEOUS","VIEW RESTRICTION")=ANS
ZUSE    S DEF="Y",QUES="ZPROT" X:EXTH ^%Q("EXTH")
        I SOFT S ANS=DEF,FEAT="ZUSE command protection" D FEAT G SETZ
        I $D(^SYS(ID,"MISCELLANEOUS","ZUSE RESTRICTION")) S DEF=^("ZUSE RESTRICTION")
        X ^%Q("SGASKYN") G:%A VIEW
SETZ    I DMB'="D" V ST+386::$V(ST+386)#256+(ANS="Y"*256)
        I DMB'="M" S ^SYS(ID,"MISCELLANEOUS","ZUSE RESTRICTION")=ANS
ECHO    S DEF="Y",QUES="DLOG" X:EXTH ^%Q("EXTH")
        I SOFT S ANS=DEF W !,"LOGIN SEQUENCE CHARACTERS:",?50,$S(DEF="N":"not",1:""),"echoed",! G SETECH
        I $D(^SYS(ID,"MISCELLANEOUS","LOGIN ECHO")) S DEF=^("LOGIN ECHO")
        X ^%Q("SGASKYN") G:%A ZUSE
SETECH  I DMB'="D" V ST+70::$V(ST+70)\256*256+(ANS="N")
        I DMB'="M" S ^SYS(ID,"MISCELLANEOUS","LOGIN ECHO")=ANS
ALTK    S DEF="3",QUES="DTRAP" X:EXTH ^%Q("EXTH")
        I SOFT S ANS=DEF,FEAT="APPLICATION INTERRUPT" D SHOKEY G SETINT
        I $D(^SYS(ID,"MISCELLANEOUS","ALTKEY")) S DEF=^("ALTKEY")
        X ^%Q("SGEN") G:%A ECHO I ANS'?1N.N!(ANS>31)!(ANS<0) D IV G ALTK
SETINT  I DMB'="D" V ST+82::$V(ST+82)#256+(ANS*256)
        I DMB'="M" S ^SYS(ID,"MISCELLANEOUS","ALTKEY")=ANS
ABORTK  S DEF=25,QUES="DABRT" X:EXTH ^%Q("EXTH")
        I SOFT S ANS=DEF,FEAT="PROGRAMMER ABORT" D SHOKEY G SETABR
        I $D(^SYS(ID,"MISCELLANEOUS","ABORT KEY")) S DEF=^("ABORT KEY")
        X ^%Q("SGEN") G:%A ALTK I ANS'?1N.N!(ANS>31)!(ANS<0) D IV G ABORTK
        F I=4,13,15,16,17,19,21 I ANS=I D IV G ABORTK
SETABR  I DMB'="D" V 2:$V(ST+132):ANS*256+($V(2,$V(ST+132))#256)
        I DMB'="M" S ^SYS(ID,"MISCELLANEOUS","ABORT KEY")=ANS
DONE    D POWER^MBP2 I %A G:'SOFT ABORTK
RETURN  Q
SHOKEY  W !,"Default ",FEAT," key:",?50,ANS,?65,"(CTRL/",$C(ANS+64),")",! Q
SHOUDA  W !,"Default ",FEAT,?50,ANS,! Q
FEAT    W !,FEAT,":",?50 W:ANS="N" "Not " W "Included",! Q
IV      W !,"   Incorrect response - enter '?' for more information",! Q
UDAQH   ;;0
VPROTH  ;;0
ZPROTH  ;;0
DLOGH   ;;0
DTRAPH  ;;0
DABRTH  ;;0
HELP    S TAG=QUES_"H" D TEXT^MBP1H Q
UDAQ    ;;2;;12.0;;1
        ;;Enter the UDA disk units, separated by commas,
        ;;that you wish to be DUAL-PORTED
VPROT   ;;0;;12.1;;1
        W !,%NUM,?6,"Restrict use of the VIEW BUFFER" W:^SYS(ID,"OPTIONS","DMC")="Y" " and DMC BLOCK MODE" Q
ZPROT   ;;1;;12.2;;1
        ;;Restrict the use of the ZUSE command
DLOG    ;;1;;12.3;;1
        ;;Echo the LOGIN SEQUENCE
DTRAP   ;;2;;12.4;;1
        ;;Enter the ASCII DECIMAL value
        ;;of the default APPLICATION INTERRUPT KEY
DABRT   ;;2;;12.5;;1
        ;;Enter the ASCII DECIMAL value
        ;;of the default PROGRAMMER ABORT KEY
