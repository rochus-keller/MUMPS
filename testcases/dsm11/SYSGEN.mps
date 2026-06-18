SYSGEN  ; DSM-11 Utilities ; Copyright 1980 DEC
        K  S $ZT="EXIT^SYSGEN",$ZE="",WORDS=0,DMB="D",SGN=1,ST=$V(44),EXTH=0 D OPEN63 G EXIT:%A
        W !!,"System generation for DIGITAL Standard MUMPS",!!?7,"Type ? for HELP at any time",!
        W !,"PART 1:",?10,"SYSGEN",!,"-------",!
HELP    S QUES="NEED",DEF="" X ^%Q("SGASKN") I %A G EXIT
        I ANS="?" W !,"Enter Y if you want help on every question" G HELP
        I ANS'?1"Y"."ES",ANS'?1"N"."O" D IV G HELP
        S EXTH=$E(ANS)="Y"
        I EXTH S QUES="EXT" X ^%Q("QUERYH") R !,"Press RETURN to continue ",A,!
ID      S SUB="0,DEFAULT/1" D DEF^SYSROU S ID=DEF
ID1     S QUES="IDENT",DEF=ID
ID2     X ^%Q("SGEN") G HELP:%A S ID=ANS
        I ANS'?1.12NUP!(ANS=0) D IV G ID1
        I ANS="*" D IDENTL G ID2
        I $D(^SYS(ID)) D CHKVER^SYSROU I %A=0 S DEF="" G ID2
CONFIG  S EDIT=1,AUTO=($V(ST+35)#2&'$D(^SYS(ID,"OPTIONS"))),^SYS(ID,"SYSTEM")=$ZV G PROC:'AUTO
        S QUES="AUTO" X ^%Q("SGASKY") G ID1:%A S AUTO=ANS="Y" G PROC:'AUTO D ^CONFIG S AUTO='ERR
        D OPEN63 G EXIT:%A
        I AUTO D ^SGAUTO
        R "",A:0
EDIT    S QUES="AUTOK" X ^%Q("SGASKN") G CONFIG:%A S EDIT=ANS="Y" G:'EDIT DONE
PROC    S DEF="" I $D(^SYS(ID,"PROCESSOR")) S DEF=^("PROCESSOR")
PROC2   S QUES="PROCT" X ^%Q("SGEN") I %A G:AUTO EDIT G ID1
        I ANS?1"MICRO"."/PDP-11" S ANS="11/23"
        I ANS'?1"11/"2N D IV G PROC2
        I $P(ANS,"/",2)>84!($P(ANS,"/",2)<23) D IV G PROC2
        S ^SYS(ID,"PROCESSOR")=ANS
MEMRY   S MEMUSE=0,DF=$V(ST+418)\32*2,SUB="'ID,MEMORY SIZE,K BYTES/'DF" D DEF^SYSROU
        S:$D(@SYV)#2 DEF=@SYV I 'EDIT S @SYV=DEF G DONE
        W !?7,"This Machine has ",DF," K Bytes of Memory",!
MEMRY2  S QUES="MEMQ" X ^%Q("SGASK") G PROC:%A I ANS<128!(ANS>4088)!(ANS#8) D IV G MEMRY2
        S @SYV=ANS
DONE    K TY,NO,SV1,SYV,WORDS,SUB
        D START^SGDISK I %A G:EDIT MEMRY G:AUTO EDIT G ID
EXIT    C 63
        I $ZE["ZEXIT"!($ZE="") K  Q
        I $ZE["INRPT" W !,"Sysgen aborted" Q
        W !,"Unrecoverable error encountered during SYSGEN: ",$ZE Q
IDENTL  Q:DEF=""  Q:$ZS(^SYS(0))=""  I $ZS(^(0))=DEF&($ZS(^(DEF))="") Q
        S ASK=0 W !,"Defined configurations are:",! F I=0:0 S ASK=$ZS(^SYS(ASK)) Q:ASK=""  W !?10,ASK
        W ! Q
OPEN63  O 63::2 E  W !,"Unable to access VIEW device 63, cannot proceed",! S %A=1 Q
        S %A=0 Q
IV      W !,"   Incorrect response - enter '?' for more information",! Q
IDENTH  ;;9
        ;;Enter the name of the configuration that you wish to edit or create.
        ;;If a configuration with this name is not already defined, a new configuration
        ;;will be created.  To modify an existing configuration, simply enter the name
        ;;of that configuration.
        ;;
        ;;The name must not exceed 12 characters or be the value 0
        ;;You will use this name whenever you wish to refer to this configuration
        ;;Type * to see a list of existing configurations.
        ;;
AUTOH   ;;9
        ;;      If you are creating a new System Configuration
        ;;      for the processor you are currently running on
        ;;                      AND
        ;;      you would like to run AUTOCONFIGURE to
        ;;      automatically find all devices on the system
        ;;      and include them in the new system configuraton
        ;;                      THEN
        ;;              Answer Y to this question
        ;;
NEEDH   ;;2
        ;;If you would like help for every question asked, enter Y
        ;;
EXTH    ;;20
        ;;Extended help will be supplied with each question you are asked
        ;;
        ;;System Generation involves creating a database file
        ;;(called a configuration) which completely describes
        ;;the hardware devices present on your computer system,
        ;;and details all software options which you request.
        ;;
        ;;You may create as many configurations as you like.  When the
        ;;DSM-11 system is booted you are then allowed to choose which
        ;;configuration you would like to run.
        ;;
        ;;On any question asked during SYSGEN, you may enter
        ;;
        ;;              ^ to return to the previous question
        ;;              ? for additionnal help
        ;;
        ;;If a value appears between angle brackets, <>, this is a default
        ;;value.  Entering RETURN will cause the default value to be used
        ;;as the answer to the question
        ;;
MEMQH   ;;7
        ;;Press <RETURN> to accept the default value of the number of K Bytes
        ;;that you want this configuration to have.
        ;;
        ;;If you wish to specify a different value for the memory size, enter
        ;;that value in K BYTES.  The value must be at least 128 K Bytes but
        ;;not more than 3840 (Unibus) or 4088 (Q-bus), and a multiple of 8.
        ;;
PROCTH  ;;9
        ;;Enter the type of processor for this configuration.  The answer should
        ;;be in the form:
        ;;
        ;;      11/XX           if the processor is a PDP-11/XX
        ;;      MICRO           if the processor is a MICRO/PDP-11
        ;;
        ;;Processors supported include all PDP-11's numbered from the 11/23 to the
        ;;11/70, and including the MICRO/PDP-11.
        ;;
AUTOKH  ;;4
        ;;If the results of AUTOCONFIGURE are not accurate, you may
        ;;choose to edit the configuration file produce by AUTOCONFIGURE
        ;;rather than accept all the values given.
        ;;
NEED    ;;1;;1.1;;1
        ;;Would you like extended help
IDENT   ;;1;;1.2;;1
        ;;Enter the configuration identifier
AUTO    ;;1;;1.3;;1
        ;;Do you wish to Auto-configure the current system
AUTOK   ;;1;;1.4;;1
        ;;Do you wish to modify this configuration information
PROCT   ;;1;;1.5;;1
        ;;Enter the processor type
MEMQ    ;;1;;1.6;;1
        ;;How many K Bytes do you wish this configuration to have
