DISKSIZ ;11-May-84 ;UTILITIES ;DISK MAINTENANCE ;MODIFY A VOLUME'S LOGICAL DISK SIZE ;JHM
        W !,"Modify Disk Volume Size",!
        O 63::1 E  W !,"View Buffer Busy",! Q
STRT    K  S PRM="Modify volume size",M=1,MAPS=2
        D GETYU^DPBEGIN G:'$D(%A) DONE G:%A STRT
        I $V(%DT+2)=0 W !,DDU," is not currently mounted",!,"You must mount this disk using the ""^MOUNT"" utility",! G DONE
        I VER'["DSM11 V3.3" W !,DDU," contains a disk which is not a valid ",$ZV," volume" G NOGO
        I MB'="M" W !,DDU," is a backup volume",!,"Only Master volumes may be modified" G DONE
        D START^%STRTAB
        S VOL=$C($V(909,0)),NUMVOL=$V(913,0),VSN="" F I=906:1:908 S VSN=VSN_$C($V(I,0)#256)
        S MNT=$V(%DT)\16384=3
        W !,DDU," is " I VOL W "Volume ",VOL," of Volume set ",VSN
        E  W !,"a mountable NON-UCI disk volume for SDP/JOURNAL/SPOOLING"
        W !,"With volume label: ",%LB,!
        I VOL>1!(NUMVOL>1&(VOL=1)) W !,"This volume is part of a multi-volume database set" G NOGO
        S PHYMAP=$V(812,0),LOGMAP=$S($V(916,0):$V(916,0),1:PHYMAP)
        W !,"Maximum physical map size: ",PHYMAP
        W !,"Current Logical map size: ",LOGMAP,!
Q1      S DEF="",QUES="SIZE" X ^%Q("EN") G:%A STRT
        I ANS'?1N.N!(ANS<2)!(ANS>PHYMAP) D IV G Q1
        D QUIET^SYSWAIT
        G OPCMP:ANS=LOGMAP,SMALL:ANS<LOGMAP
        S LMB=LOGMAP+1*400-1,%MP=PHYMAP,LOGMAP=ANS
Q2      S QUES="SURE" X ^%Q("ASKN") G:%A Q1
        G:ANS="N" Q1
        D INAREA^DPINIT G WLB
SMALL   S $ZT="MAPER",LOGMAP=ANS F MAP=PHYMAP-1:-1:LOGMAP-1 V MAP+1*400-1:DDU D
        .S OK=$V(1022,0)=399 I OK Q
        .S CODE=$V(1008,0),TYP=$S(CODE=13107:"Journal",CODE=43690:"SDP",CODE=56173:"Spool",CODE=21845:"DATA",1:"???")
        .ZT "MAP"
        U 63:(::"Z"),0 V 0:DDU S %B=910 D %BN G:'%BN WLB
        S UCB=%BN,UCINO=0
UTAB    V UCB:DDU S UCINO=UCINO+1,OFF=UCINO-1*20,U=$V(OFF,0)
        I 'U G WLB
        S UNM=$C(U\2048+64)_$C(U#2048\64+64)_$C(U#64\2+64)
        I $V(OFF+10,0)+1>LOGMAP D UCIERR W !,"UCI Global Data Growth Area points beyond map ",LOGMAP-1 D RUNGAM G NOGO
        I $V(OFF+12,0)+1>LOGMAP D UCIERR W !,"UCI Global Pointer Growth Area points beyond map ",LOGMAP-1 D RUNGAM G NOGO
        I $V(OFF+8,0)+1>LOGMAP D UCIERR W !,"UCI Routine Growth Area points beyond map ",LOGMAP-1 D RUNGAM G NOGO
        S %B=2+OFF D %BN S GDIR=%BN
GDIR    V GDIR:DDU S %PTR=0,END=$V(1022,0) G UTAB:'END
F1      S GNM="" F %PTR=%PTR:1 S %C=$V(%PTR,0)#256,GNM=GNM_$C(%C\2) Q:'(%C#2)
        S (%B,%PTR)=%PTR+3 D %BN
        I %BN\400+1>LOGMAP D GLOERR W !,"New Data Growth area pointer beyond map ",LOGMAP-1 D RUNGLO G NOGO
        S %PTR=%PTR+6 I %PTR+1<END G F1
        S %B=1014 D %BN S GDIR=%BN G:GDIR GDIR G UTAB
WLB     I MNT S STR="" D  I STR="" W !,"Can't find this volume in the volume set table" G NOGO
        .F I=1:1 S STR=$O(STR(STR)) Q:STR=""  I $P(STR(STR,VOL),":")=DDU D  Q
        ..S ST=$V(44),STRTAB=$V(ST+34)#256*STR+$V(ST+12)
        ..S PTR=VOL-1*3+8+STRTAB
        ..I PTR#2 V PTR-1::LOGMAP#256*256+($V(PTR-1)#256),PTR+1::$V(PTR+2)*256+(LOGMAP\256)
        ..E  V PTR::LOGMAP
        ..V 0:$V(STRTAB+4):LOGMAP
        U 63:(::"Z"),0 V 0:DDU,916:0:LOGMAP S $ZT="WLBER" V -16777216:DDU S $ZT=""
        G OPCMP
IV      W !,"Invalid response - Type ? for more help" Q
%BN     S %BN=$V(%B+2,0)#256*256+($V(%B+1,0)#256)*256+($V(%B,0)#256) Q
WLBER   U 0 W !,"Error writing label block to ",DDU,!,"$ZE = ",$ZE G DONE
MAPER   I $ZE'["ZMAP" U 0 W !,"Error reading map ",MAP," (block # ",MAP*400,") on ",DDU,!,"$ZE = ",$ZE G NOGO
        W !,"Map block ",MAP," indicates that blocks within its map area"
        W !,"are currently allocated for ",TYP
        W !!,"You must deallocate these blocks before the logical disk size"
        W !,"may be reduced.",! G NOGO
SIZE    W !,"Enter the number of maps to assign to this volume" Q
SIZEH   W !,"Enter the number of maps that you would like this volume"
        W !,"to logically hold.  This number must be less than or equal"
        W !,"to the actual physical size (in maps) of the disk volume."
        W !,"If the logical size is already smaller than the physical"
        W !,"maximum, this value may be increased.",! Q
SURE    W !,"This operation will remove any SDP, Journal, or SPOOL areas"
        W !,"which may reside beyond map ",LOGMAP-1,"."
        W !!,"Ok to proceed" Q
UCIERR  W !,"UCI table entry for UCI, ",UNM,", shows that" Q
RUNGAM  W !!,"DO ^DGAM to modify this entry" Q
GLOERR  W !,"Global, ",GNM,", in UCI, ",UNM,", contains a" Q
RUNGLO  W !!,"DO ^%GLOMAN to modify this characteristic" Q
OPCMP   W !,"Operation complete" G DONE
NOGO    W !,"This disk's volume size may not be modified"
DONE    C 63 D RELSYS^SYSWAIT Q
