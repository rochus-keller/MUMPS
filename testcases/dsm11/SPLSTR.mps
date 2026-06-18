SPLSTR  ;26-Apr-84 ;UTILITIES ;SPOOLING ;SHOW SPOOL STATUS ;JBH
        I ^SYS(0,"STARTUP","SPOOLING")'="Y" W !,"SPOOLING is not now running." G DIR
        W !,"SPOOLING is now running, the DESPOOLER is "
        I ^("DESPOOLER")'="Y" W "not running." G OFT
        E  W "running on device ",^("DEFAULT SPOOL DEVICE")
OFT     W !
        S ST=$V(44),MM=$V(ST+136),SIZ=$V(1,MM),COUNT=$V(0,MM)#256,OFT=2,F=0
        F I=0:1:COUNT-1 I $V(I*SIZ+OFT,MM) W "File ",$V(I*SIZ+OFT,MM)#256," is open for job ",$V(I*SIZ+OFT+2,MM)#256\2,! S F=F+1
        I F=0 W !,"No SPOOL files are currently open."
DIR     I '$D(^SYS(0,"SPOOL SPACE",1)) W !,"No SPOOL space is currently allocated.",! G DONE
        S DIR=^(1,"START"),MAP=DIR\400,MAPS=^("END")-DIR+2\400,DDU=^("DISK")
        S BAS=MAP*400,TOT=MAPS*399-1-(DIR#400)
        W !,"The current SPOOL space on ",DDU," starts at block ",DIR," and has ",TOT," data blocks",!
        C 63 O 63:2:1 I '$T W !,"Can't get the view buffer to show the directory.",! G DONE
        U 63:(1:1),0 V DIR:DDU F FILE=1:1:255 D
        .U 63:(1:1),0 S BL=$V(FILE*4+2,0)#256*65536+$V(FILE*4,0) I BL=0 Q
        .S DEV=$V(FILE*4+3,0)
        .U 63:(2:1),0 V BL+BAS:DDU
        .S END=$V(10,0)#256*65536+$V(8,0)
        .S USE=$V(11,0)*65536+$V(12,0)
        .S %DT=$V(14,0) D %CDS^%H
        .S %TM=$V(18,0)#256*65536+$V(16,0) D %CTS^%H
        .S @("UCN=$ZU("_($V(19,0)#32)_","_($V(19,0)\32)_")")
        .I END=0 S LSEQ=0,USEQ=0 G TYPE
        .V END+BAS:DDU S LSEQ=$V(3,0)*65536+$V(4,0)
        .V USE+BAS:DDU S USEQ=$V(3,0)*65536+$V(4,0)
TYPE    .W !,"File ",FILE,"-",DEV," for ",UCN," on ",%DAT1," at ",%TIM1
        .I END>0 W " has ",USEQ," blocks in use out of ",LSEQ
        .E  W " but is of unknown size."
DONE    C 63 Q
FREE    S DIR=^SYS(0,"SPOOL SPACE",1,"START"),DDU=^("DISK")
        S BAS=DIR-(DIR#400)
        C 63 O 63 V DIR:DDU
        F I=0:1 S B=$V(2,0)#256*65536+$V(0,0) Q:'B  V B+BAS:DDU
        W !,"There are ",I," blocks in the free list",!
        C 63 Q
