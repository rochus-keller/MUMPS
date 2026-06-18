FASTDBT ;
START   S %CL=1 G S2
NOCLS   S %CL=0
S2      C 63 O 63::2 I '$T U 0 W !,"View buffer busy, can't do disk tally",! G EXIT
        S %ISAV=$I U 63:(1:1) U %ISAV
        S QUES="ALL" D ASKYN G DONE:%NULL S ALL=Y
        S DTAB=$V($V(44)+224),GRTOT=0 D TYPES^SYSROU
        F D=DTAB:4:DTAB+255 I $V(D+1)\128#2 D DISK
        W !,"Grand total avail. = ",GRTOT
        W !!,"Maps marked ""FREE"" are available for allocation to Journal, Spool, or SDP.",!
DONE    K QUES,DTAB,D,TYY,UU,DDU,YES,ALL,Y,BLK0,GRTOT
        K PREV,MPS,M0,MP0,CT,MBLK,AVAIL,TYP,USE,OLDAVAIL,OLDUSE
        K %ISAV,%NULL,TAV,TYPES
EXIT    C:%CL 63 K %CL Q
DISK    S TYY=D-DTAB\32,UU=D-DTAB#32\4,YES=ALL
        S DDU=$P(TYPES,",",TYY+1)_UU
        D:'ALL QUERY Q:'YES
        S BLK0=0,MPS=$V(D+2)
        S TAV=0 W !!!,"Disk  ",DDU,!!
        W "Map #    Blks avail.  Use",!
        W "-------  -----------  ---",!!
        S PREV=100 F M0=0:1:MPS S MBLK=M0*400+399+BLK0 D MAPGET
        W !,"  Total avail =  ",TAV,! S GRTOT=GRTOT+TAV Q
MAPGET  ;
        I M0=MPS D:PREV'=100 PRINT Q
        S AVAIL=0,$ZE="ERR" V MBLK:DDU S $ZE="" G NOERR
ERR     S $ZE="",USE="ERROR READING THIS MAP BLOCK",TYP=100 G TYPCHK
NOERR   I $V(1006,0)=65535&($V(1012,0)=32769) G OK
NOTOK   S TYP=100,USE="Not a valid map block" G TYPCHK
OK      I $V(1008,0)=56173 S USE="* SPOOL *",TYP=4 G TYPCHK
        I $V(1008,0)+$V(1010,0)'=65535 G NOTOK
        S AVAIL=$V(1022,0) G SPECL:$V(1008,0)'=21845
        I AVAIL=399 S USE="* FREE *",TYP=1 G TYPCHK
        I AVAIL=398,M0=0 S USE="* FREE *",TYP=100 G TYPCHK
        S TYP=100 S:AVAIL=0 TYP=5 S USE="(DATABASE)" G TYPCHK
SPECL   I AVAIL S USE="Map invalid - invalid count word = "_AVAIL
        I  S AVAIL=0,TYP=100 G TYPCHK
        I $V(1008,0)=13107 S USE="* JOURNAL *",TYP=3 G TYPCHK
        I $V(1008,0)=43690 S USE="* SDP *",TYP=2 G TYPCHK
        G NOTOK
TYPCHK  S TAV=TAV+AVAIL I TYP=100 D:PREV'=100 PRINT G NEWTYP
        I TYP=PREV S CT=CT+1 Q
        D:PREV'=100 PRINT S MP0=M0,CT=0,OLDUSE=USE,OLDAVAIL=AVAIL
NEWTYP  S PREV=TYP
        I TYP=100 W " ",M0,?13,AVAIL,?22,USE,!
        Q
PRINT   G PR1:CT>0 W " ",MP0 W:CT "-",MP0+CT W ?13,OLDAVAIL,?22,OLDUSE,! Q
PR1     W " ",MP0 W:CT "-",MP0+CT W ?11,CT+1,"*",OLDAVAIL,?22,OLDUSE,! Q
ASKYN   U 0 S %NULL=0 D @QUES R " [Y/N] ?  > ",Y,! I Y="" S %NULL=1 Q
        G ASKYN:"YN"'[$E(Y,1) S Y=$E(Y,1)="Y" U %ISAV Q
ALL     W "Tally all disks currently mounted" Q
QUERY   S QUES="DSKQ" D ASKYN S YES=Y S:%NULL YES=0 Q
DSKQ    W !,"Fast tally for disk  ",DDU," " Q
