SGDMC   ;25-Apr-83 ;UTILITIES ;SYSGEN ;GET DMC SPECIFIC INFO ;JHM
        Q
START   W !,"PART 4:",?10,"CONFIGURE DMC/DMR-11's and DDP",!,"-------",!
        S MAXLIN=^SYS(ID,"CONTROLLER","DMC11")+^("DEQNA")+^("DEUNA"),(DMC,LINES,NODES)=0 G DONE:'MAXLIN
        F CON=0:1:^SYS(ID,"CONTROLLER","DMC11")-1 D  I %A G:CON=0 RETURN S CON=CON-2
        .W !,"DMC/DMR-11 controller #",CON,!
        .I '$D(^SYS(ID,"CONTROLLER","DMC11",CON,"DDP")) S ^SYS(ID,"CONTROLLER","DMC11",CON,"DDP")="Y"
HDX     .S DEF="N" I $D(^SYS(ID,"CONTROLLER","DMC11",CON,"HALF DUPLEX")) S DEF=^("HALF DUPLEX")
        .S QUES="HALF" X ^%Q("SGASKYN") Q:%A  I ANS="" D IV G HDX
        .S ^SYS(ID,"CONTROLLER","DMC11",CON,"HALF DUPLEX")=$E(ANS) I $E(ANS)="N" S ^("PRIMARY")="Y"
        .E  D  G:%A HDX
        ..S DEF="N" I $D(^("PRIMARY")) S DEF=^("PRIMARY")
PRI     ..S QUES="PRMRY" X ^%Q("SGASKYN") Q:%A  I ANS="" D IV G PRI
        ..S ^SYS(ID,"CONTROLLER","DMC11",CON,"PRIMARY")=$E(ANS)
        .I '$D(^SYS(ID,"CONTROLLER","DMC11",CON,"DDP")) S ^SYS(ID,"CONTROLLER","DMC11",CON,"DDP")="Y"
DDPL    .S DEF=^SYS(ID,"CONTROLLER","DMC11",CON,"DDP"),QUES="WANT" X ^%Q("SGASKYN") G:%A HDX
        .S ^SYS(ID,"CONTROLLER","DMC11",CON,"DDP")=$E(ANS)
        .I $E(ANS)="N" S DMC=DMC+1 Q
        .S ^SYS(ID,"DDP","LINES",LINES,"CONTROLLER")="DMC11",^("CONTROLLER NUMBER")=CON,^("NODES")=1
        .S ^("V3")="N"
        .S NODES=NODES+1,LINES=LINES+1
        F CONTYP="DEUNA","DEQNA" I ^SYS(ID,"CONTROLLER",CONTYP) F CON=0:1:^(CONTYP)-1 D  G:%A START
NOD     .I $D(^SYS(ID,"DDP","LINES",LINES,"NODES")) S DEF=^("NODES")
        .E  S DEF=""
        .S QUES="NODQ" X ^%Q("SGEN") Q:%A
        .I ANS'?1N.N!(ANS>10) D IV G NOD
        .S ^SYS(ID,"DDP","LINES",LINES,"NODES")=ANS,LINES=LINES+1,NODES=NODES+ANS
        .S ^("CONTROLLER")=CONTYP,^("CONTROLLER NUMBER")=CON,^("V3")="N"
DONE    S ^SYS(ID,"DDP","LINES")=LINES,^SYS(ID,"DMC","LINES")=DMC
        F I=0:1:LINES-1 I '$D(^SYS(ID,"DDP","LINES",I,"SERVICE")) S ^("SERVICE")="In Service"
        S ^SYS(ID,"DDP","NODES")=NODES
        S ^SYS(ID,"OPTIONS","DDP")=$S(LINES:"Y",1:"N"),^("DMC")=$S(DMC:"Y",1:"N")
        I 'LINES!'$D(^SYS(ID,"MEM.ALLOC","DDP BUFFERS")) S ^("DDP BUFFERS")=0
        I ^("DDP BUFFERS")=0 S ^("DDP BUFFERS")=$S(NODES*10+20<60:NODES*10+20,1:60)*512*(LINES>0)
        S ^("DDP BASE TABLES")=128*LINES+63\64*64
        S ^SYS(ID,"MEM.ALLOC","RV TABLE")=$V(ST+404)*64*(NODES+1)*(LINES>0)
        S ^SYS(ID,"DDP","SERVERS")=NODES
        F I=1:1 K ^SYS(ID,"DDP","LINES",LINES) S LINES=$O(^(LINES)) Q:LINES=""
        K MAXLIN,CON,HLP,CODE,V3,DMC,LINES,NODES
        D START^SGSOFT I %A,^SYS(ID,"CONTROLLER","DMC11") G START
RETURN  Q
IV      W !,"   Incorrect response - enter '?' for more information",! Q
WANTH   ;
NODQH   ;
HELP    S TAG=QUES_"H" D TEXT^SGBUFFH Q
V3H     ;;5
        ;;DSM-11 Version 3.0 systems use a DDP message format that is different
        ;;from the format used by DSM-11 Version 3.1 . You must specify whether the
        ;;system connected to this DDP line is a DSM-11 Version 3.0 system so that
        ;;the two systems will understand each other.
        ;;
HALFH   ;;7
        ;;Half/Full duplex is related to the data connection between this
        ;;DMC-11 and its remote DMC-11.  Generally, DMC's linked via a
        ;;coaxial cable will be running FULL-DUPLEX.  DMC's linked via a
        ;;telephone line may be run either FULL or HALF duplex.  If you
        ;;do not know how your DMC-11 is configured, contact your DIGITAL
        ;;FIELD SERVICE representative.
        ;;
PRMRYH  ;;5
        ;;In HALF-DUPLEX operation, one side of the DMC-11 to DMC-11
        ;;connection must be designated as the PRIMARY.  Answer "Y" if
        ;;this DMC-11 is to be the PRIMARY station.
        ;;
        ;;
HALF    ;;0;;4.1;;1
        W !,%NUM,?6,"Is this device HALF-DUPLEX" Q
PRMRY   ;;0;;4.2;;1
        W %NUM,?6,"Is this device the primary station" Q
WANT    ;;0;;4.3;;1
        W %NUM,?6,"Will this device be used for DDP" Q
V3      ;;0;;4.4;;1
        W %NUM,?6,"Is this device connected to a Version 3.0 system" Q
NODQ    ;;0;;4.5;;1
        W !,%NUM,?6,"How many DSM nodes are connected to ",CONTYP," #",CON Q
