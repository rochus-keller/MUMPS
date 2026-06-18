MBP2    ;1-Nov-83 ;UTILITIES ;SYSGEN ;PART 3 OF MODIFY BASIC PARAMETERS ;JHM
        Q
POWER   S DEF=40,QUES="DPWR" X:EXTH ^%Q("EXTH")
        I SOFT S ANS=DEF,FEAT="POWER FAIL RESTART" D SHOSEC G SETPWR
        I $D(^SYS(ID,"MISCELLANEOUS","POWER RESTART DELAY")) S DEF=^("POWER RESTART DELAY")
        X ^%Q("SGEN") G:%A RETURN I ANS'?1N.N!(ANS<0)!(ANS>500) D IV G POWER
SETPWR  S ^SYS(ID,"MISCELLANEOUS","POWER RESTART DELAY")=ANS
        I DMB'="D" V ST+420::^("LINE FREQUENCY")*ANS
LOGOUT  S DEF=15,QUES="DPAR" X:EXTH ^%Q("EXTH")
        I SOFT S ANS=DEF,FEAT="TELEPHONE DISCONNECT" D SHOSEC G SETPAR
        I $D(^SYS(ID,"MISCELLANEOUS","LOGOUT DELAY")) S DEF=^("LOGOUT DELAY")
        X ^%Q("SGEN") G:%A POWER I ANS'?1N.N!(ANS<0)!(ANS>250) D IV G LOGOUT
SETPAR  I DMB'="D" V ST+282::$V(ST+282)#256+(ANS*256)
        I DMB'="M" S ^SYS(ID,"MISCELLANEOUS","LOGOUT DELAY")=ANS
DIVAC   S DEF=12,QUES="DIV" X:EXTH ^%Q("EXTH")
        I SOFT S ANS=DEF W !,"Number of significant DIGITS for DIVISION:",?50,ANS,! G SETDIV
        I $D(^SYS(ID,"MISCELLANEOUS","DIVSIG")) S DEF=^("DIVSIG")
        X ^%Q("SGEN") G:%A LOGOUT I ANS'?1N.N!(ANS<10)!(ANS>31) D IV G DIVAC
SETDIV  I DMB'="D" V ST+264::$V(ST+265)*256+ANS
        I DMB'="M" S ^SYS(ID,"MISCELLANEOUS","DIVSIG")=ANS
HERZ    S DEF="Y",QUES="DFREQ"
        I $D(^SYS(ID,"MISCELLANEOUS","LINE FREQUENCY")) S:^("LINE FREQUENCY")=50 DEF="N"
        X ^%Q("SGASKYN") I %A G:SOFT RETURN G DIVAC
        S FQ=$S($E(ANS)="Y":60,1:50)
        I DMB'="D" V ST+36::FQ*256/10
        I DMB'="M" S ^SYS(ID,"MISCELLANEOUS","LINE FREQUENCY")=FQ
INPAC   S QUES="PAC" X:EXTH ^%Q("EXTH")
        W !,"12.10",?6 R "Enter the 3-character Programmer Access Code (PAC) > ",ANS,!
        G:ANS="^" HERZ I ANS="?" X ^%Q("QUERYH") G INPAC
        I $L(ANS)'=3 D IV G INPAC
        I DMB'="D" V ST+76::$A($E(ANS,2))*256+$A($E(ANS,1)),ST+78::$V(ST+79)*256+$A($E(ANS,3))
        I DMB'="M" S ^SYS(ID,"PROGRAMMER ACCESS CODE")=ANS
DONE    K FEAT,DMB,FQ
RETURN  Q
FEAT    W !,FEAT,":",?50 W:ANS="N" "Not " W "Included",! Q
SHOSEC  W !,"Time delay for ",FEAT,":",?50,ANS," seconds",! Q
IV      W !,"   Incorrect response - enter '?' for more information",! Q
DPWRH   ;;0
DPARH   ;;0
DIVH    ;;0
DFREQH  ;;0
PACH    ;;0
HELP    S TAG=QUES_"H" D TEXT^MBP1H Q
DPWR    ;;2;;12.6;;1
        ;;Enter the number of seconds to delay
        ;;SYSTEM RESTART after a POWER FAILURE
DPAR    ;;2;;12.7;;1
        ;;Enter the number of seconds to delay TELEPHONE
        ;;DISCONNECT after LOGGING OUT of a MODEM CONTROLLED LINE
DIV     ;;2;;12.8;;1
        ;;Enter the number of
        ;;SIGNIFICANT DIGITS to include in DIVISION computations
DFREQ   ;;1;;12.9;;1
        ;;Is the LINE FREQUENCY 60 HZ
