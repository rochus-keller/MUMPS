%FGR    ;14-Mar-85 ;DSM-11 ;UTILITIES ;Restore a global copied to tape by %FGC ;RWB
        W !,?15,"FAST GLOBAL RESTORE",!!
        D %NOCNTY^%TDN
        S (%TDI,%TDJ)=0
        D %MTDN^%TDN
        S (%TD,%PROT)="Q"
        O 63:(5:1:5):0 E  W !,"VIEW BUFFER NOT ACCESSIBLE" Q
        S %FLAG="S" D %CONT1^%GGP
        S (PROTON,OJ)=0
        S %TFLAG="CB" D ^%TDN I %TD="Q" C 63 G MAQUIT
        C %TD,63 S PROG="F"
        S $ZT="ERROR^%FGR"
        S PROTON=0
        F BLOOP=1:1 Q:PROG="Q"  D RLOOP
MAQUIT  I OJ D MJOB
        C %TD I %TD'="Q" O %TD U %TD W *5 C %TD
        I PROTON D OJOB C 63 O 63:(1:1:1:"C") S %FLAG="FGR" D %START^%GGP D RESPRO^%TDN S PROTON=0 D MJOB
        D %CNTY^%TDN
        C 63
        K %GFINP,%GFINB,%ARES,%N,%NAME,%GNAME,%DATL,%GLBPTR,%PTRL,%S,%TD
        K %F,ERR,OJ,V,W,Z
        K %TFLAG,%LVL,%I,%UCN,P,Q,BB,AN,BLOOP,PROG,M,N,F,G,A,I,%DEV
        K %DO,%J,%K,%OPE,%RHRES,%RIGHT,%TAPENO,%TS,%TYPE,BIT,CMCNT,CNT,HH
        K NN,LL,NL,OP,ZA,ZE,%DEN,%TDI,%USMOD
        K %UCIN,%UCNUM,%STB
        K %FLAG,%LAST,%PROT,%GFINQ,PROTON,%TDI,%TDJ
        Q
UNDBL   V %STB+74::$J*512 S OJ=1 C 63 O 63:(1:1:1:"C") V %STB+74::0 S OJ=0 Q
DBL     V %STB+74::$J*512 S OJ=1 C 63 O 63:(5:1:5:"C") V %STB+74::0 S OJ=0 Q
OJOB    V %STB+74::$J*512 S OJ=1 Q
MJOB    V %STB+74::0 S OJ=0 Q
RLOOP   S PROG="F",$ZT="RLP^%FGR",NL=0,NN=0
        D FR^%FGR2
        Q:PROG="Q"
ST1     I OJ D MJOB
        U 0 R !,"ENTER NEW NAME FOR GLOBAL OR RETURN TO LEAVE NAME UNCHANGED:  ",AN
        I AN="^" S PROG="Q" Q
        I AN="" S %GNAME=%NAME G ST2
        I $L(AN)=$L(%NAME) S %GNAME=AN G ST2
        U 0 R !,"NAMES MUST BE OF EQUAL LENGTH.  TRY AGAIN? ",AN G:(AN="Y")!(AN="y") ST1
        S PROG="Q" Q
ST2     O 63::0 E  U 0 W !,"VIEW BUFFER NOT ACCESSIBLE" S PROG="Q" Q
        D OJOB
        S %FLAG="FGR" D %START^%GGP
        G:%GLBPTR'="" ST3
        U 0 R !,"TRY AGAIN?  ",AN G:(AN="Y")!(AN="y") ST1 S PROG="Q" Q
ST3     O 63::0 E  U 0 W !,"VIEW BUFFER NOT ACCESSIBLE" S PROG="Q" Q
        U 63 V %GLBPTR:%S S P=$V(1021,0)
        G:P\2#2 ST4 U 0 R !,"DUMMY GLOBAL CORRUPTED   TRY AGAIN?  ",AN
        G:(AN="Y")!(AN="y") ST1 S PROG="Q" C 63 Q
ST4     S P=$V(1018,0)+($V(1020,0)#256*65536) G:'P ST5
        U 0 R !,"GLOBAL HAS TOO MANY POINTER BLOCKS  TRY AGAIN?  ",AN
        G:(AN="Y")!(AN="y") ST1 S PROG="Q" C 63 Q
ST5     S P=$V(1,0)+2,P=$V(P,0)#256+($V(P+1,0)#256*256)+($V(P+2,0)#256*65536)
        V P:%S
        S Q=$V(1021,0) G:Q\8#2 ST6
        U 0 R !,"DUMMY GLOBAL CORRUPTED  TRY AGAIN?  ",AN
        G:(AN="Y")!(AN="y") ST1 S PROG="Q" C 63 Q
ST6     S Q=$V(1018,0)+($V(1020,0)#256) G:'Q ST7
        U 0 R !,"DUMMY GLOBAL HAS MORE THAN ONE DATA BLOCK  TRY AGAIN?  ",AN
        G:(AN="Y")!(AN="y") ST1 S PROG="Q" C 63 Q
ST7     U 0 W !!,"RESTORE OF ",%GNAME," BEGINNING: " D D^%TDN W !!
        D SETPRO^%TDN S PROTON=1 D MJOB
        S %PTRL=%GLBPTR,%DATL=P D ^%LNKMP
        S PROG="G"
        G:%ARES=2 ST8
        U 0 R !,"NOT ENOUGH FREE BLOCKS OR MAP ERRORS  TRY AGAIN?  ",AN
        G:(AN="Y")!(AN="y") ST1 S PROG="Q" Q
ST8     G:%GNAME=%NAME ST9
        F I=0:1:$L(%GNAME)\2-1 S NL(I)=$A($E(%GNAME,(I+1)*2))*512+256+($A($E(%GNAME,I*2+1))*2+1)
        I '($L(%GNAME)\2) S NL=0
        E  S NL=I+1
        I $L(%GNAME)#2 S NN=$A($E(%GNAME,$L(%GNAME)))*2
        E  S NL(NL-1)=NL(NL-1)-256
ST9     D DBL
        O @(%DEV) E  W !,"TAPE NOT OPENABLE" C 63 S PROG="Q" Q
        D OJOB H 3
        F I=1:1:$V(%STB+32) I $V(4*I+2,$V(%STB+506))#256<128 V 4*I+2:$V(%STB+504):65535
        D MJOB
        V %LVL("LAST"):%S
        S J=1
        V 804:0:%UCIN
        F I=806:2:806+($L(%GNAME)*2-2) V I:0:$A($E(%GNAME,J)) S J=J+1
        V I+2:0:0
        V -%LVL("LAST"):%S
        F %I=1:1:%LVL-1 D %PTRLV^%FGR1  Q:PROG="Q"
        G:PROG'="Q" ST10
        I %TD'="Q" U %TD W *5 C %TD S %TD="Q"
        D UNDBL D CLEAN^%LNKMP
        U 0 W !,"%FGR FAILED WHILE RESTORING GLOBAL LEVEL ",%I,". %FGR IS TERMINATED" Q
ST10    D %DTLVL^%FGR1
        G:PROG'="Q" ST11
        I %TD'="Q" U %TD W *5 C %TD S %TD="Q"
        D UNDBL D CLEAN^%LNKMP
        U 0 W !,"%FGR FAILED AT DATA LEVEL. %FGR IS TERMINATED" Q
ST11    C %TD D UNDBL D OJOB S %FLAG="FGR" D %START^%GGP BREAK 0 U 63:(1:1:"CP")
        S M=%PTRL-(%PTRL#400)+399
        S N=%DATL-(%DATL#400)+399
        S F=%PTRL#400,G=%DATL#400
        V M:%S V F*2:0:0,1022:0:$V(1022,0)+1 V -M:%S
        V N:%S V G*2:0:0,1022:0:$V(1022,0)+1 V -N:%S
        V %GFINB:%S S A=%LVL(1,1)-399+%LVL(1,2)
        I %GFINP#2 V (%GFINP-1):0:$V(%GFINP-1,0)#256+(A#256*256),%GFINP+1:0:A\256
        E  V %GFINP:0:A#65536,%GFINP+2:0:$V(%GFINP+3,0)#256*256+(A\65536)
        V -%GFINB:%S
        U 0 W !,"THE GLOBAL ",%GNAME," IS RESTORED"
        U 63:(1:1:"C") BREAK 1 D MJOB S PROG="H"
        S BB=%UCN*256+%UCN
        D CLNUP1^%FGR1 D CLNUP2^%FGR1
        U 0 W !!,"FINISHED: " D D^%TDN
        S %FLAG="FGR" D OJOB D %START^%GGP D RESPRO^%TDN D MJOB S PROTON=0 C 63
        Q
ERROR   S FGZA=$ZA,FGZE=$ZE D DISPER^%TDN
        I %TD'="Q" C %TD S %TD="Q"
        I PROG="G" D CLEAN^%LNKMP
        S PROG="Q" G MAQUIT
RLP     ZQ
