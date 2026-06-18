%FGC    ;19-Feb-85 ;DSM-11 ;UTILITIES ;FAST GLOBAL COPY ;RWB
        S C=0,R=0
        S $ZT="%ERROR^%FGC"
        S %TAPNO=1
        S %GNUM=0
        S (%TD,%PROT)="Q"
        W !,?14,"FAST GLOBAL COPY"
        D %NOCNTY^%TDN
        D %MTDN^%TDN
        W !!,"ENTER THE UNSUBSCRIPTED NAMES OF THE GLOBALS TO COPY: ",!!
        K %GLOBS
        O 63:(1:1:1):0 E  W !,"VIEW BUFFER NOT ACCESSIBLE" Q
        D %BLDAR W !!
        I %GLOBS(1,"NAME")="" G %END
%TOP    S %GNUM=%GNUM+1,%WRT=0
        S %GNAME=%GLOBS(%GNUM,"NAME")
        G:%GNAME'="" %TOP2
        I %TD'="Q" O %TD U %TD W *3 W *3 W *5 C %TD
        G %END
%TOP2   V %STB+74::$J*512 H 2
        S %FLAG="FGC" D %START^%GGP
        D SETPRO^%TDN
        V %STB+74::0
        BREAK 0
        U 63:(1:1:"P") V 399:%S
        S J=1
        V 836:0:%UCIN,834:0:%PROT,832:0:12345
        F I=838:2:838+($L(%GNAME)*2-2) V I:0:$A($E(%GNAME,J)) S J=J+1
        V I+2:0:0
        V -399:%S U 63:(1:1:"C")
        BREAK 1
        V %STB+74::$J*512 C 63 O 63:(13:1) V %STB+74::0
        I %TD="Q" S %TFLAG="CB" D ^%TDN G %ENDD:%TD="Q",%TOP3
        O @(%TD_":(""CB"_%DEN_"""):0") E  U 0 W !,"TAPE DRIVE NOT OPENABLE" S %TD="Q" G %ENDD
%TOP3   U 63:(1:1)
        V %GLBPTR:%S
        F %I=1:1 Q:$V(1021,0)\4#2  D %LEVEL
        S %LVL("DATA")=0,I=0
%LASTL  D %LEFEG S %LVL(%I,"NEXT")=%NXTPTR
%LAS1   D %CNTDT S I=I+1 D %RITLK I %NX V %NX:%S G %LAS1
        S %LVL(%I)=I,%TOTAL=0
        F I=1:1:%I S %TOTAL=%LVL(I)+%TOTAL
        S J=%TOTAL+%LVL("DATA")
        U 0
        W !!,?10,"BLOCKS CONTAINED IN ",%GNAME,!
        W !,?10,"LEVEL",?20,"NUMBER OF BLOCKS"
        W !,?10,"-----",?20,"------ -- ------",!
        F I=1:1:%I W !,?(15-$L(I)),I,?(36-$L(%LVL(I))),%LVL(I)
        W !,?11,"DATA",?(36-$L(%LVL("DATA"))),%LVL("DATA")
        W !,?10,"TOTAL",?(36-$L(J)),J,!!
        W !!,"FAST GLOBAL COPY OF ",%GNAME," BEGINNING: " D D^%TDN W !!
        S X=%GLBPTR,BEGT=%TAPNO,%GNAME=%GNAME_"#",%J=1
%WH     U 63:(13:1)
        V 0:0:%TAPNO
        F J=1:1:$L(%GNAME) V (J*2):0:$A($E(%GNAME,J))
        S J=(J*2)+2
        V J:0:BEGT S J=J+2
        F I=1:1:%I V J:0:%LVL(I) S J=J+2
        V J:0:0
        V J+2:0:%LVL("DATA")#65536
        V J+4:0:%LVL("DATA")\65536
        S J=J+6,I=$H_"#",K=1
        F J=J:2:$L(I)*2+J V J:0:$A($E(I,K)) S K=K+1
        V 1020:0:15*256
        U %TD:(1024:12288) W *4
        S Y=%TD
        F I=1:1:%WRT U 63:(R:1),Y:(1024:(R-1)*1024) S X=$V(1020,0)#256*65536+$V(1018,0) W *4 S R=R+1 I R>6 S R=1
        S S=%S
        H 1
        G:'X N
L       F C=C:1 F R=1:1:6 U 63:(R:1),Y:(1024:R-1*1024) V X:S S X=$V(1020,0)#256*65536+$V(1018,0) W *4 G:'X M
M       F E=1:1:5 U Y:(1024:(E-1)*1024) W *4
        S E=0
        F A1=1:1:5 W *1
N       I %J>%I U 0 W !,"FINISHED: " D D^%TDN W !! C %TD V %STB+74::$J*512 C 63 O 63:(1:1:1:"C") V %STB+74::0 D %CNTZ G %TOP
        S X=%LVL(%J,"NEXT"),%J=%J+1 H 2 G L
%CNTZ   U 63:(1:1:"C") D RESPRO^%TDN
        BREAK 0
        U 63:(1:1:"P") V 399:%S V 832:0:0,834:0:0,836:0:0,838:0:0
        V -399:%S U 63:(1:1:"C")
        BREAK 1
        Q
%ERROR  S I=$ZA,J=$ZE
        G:J="" EREND
        S $ZE="",$ZT="ERER^%FGC"
        I ((I\1024#2))&(J["MTERR")&C D  S $ZT="%ERROR^%FGC" G %ENDD:%TD="Q",%WH
        .U %TD S A2=$S(E=5:5,1:4) F A1=1:1:A2 W *1
        .W *3 W *3 W *5 C %TD S %TD="Q"
        .U 0 W !,"** END OF CURRENT TAPE **"
        .S %TFLAG="CB" U 63:(1:13) D ^%TDN
        .S %TAPNO=%TAPNO+1,C=0
        .I E=0 S R=R+3,%WRT=4 I R>6 S R=R-6
        .I E=1 S R=R+4,%WRT=3 I R>6 S R=R-6
        .I E=2 S R=R+5,%WRT=2 I R>6 S R=R-6
        .I E=3 S %WRT=1
        .I (E=4)!(E=5) S %WRT=0
        .D %SCTXT
        S FGZA=I,FGZE=J D DISPER^%TDN
        G:%TAPNO=1 EREND
        D %RCTXT S C=0
        C %TD S %TD="Q"
        S %TFLAG="CB" U 63:(1:13) D ^%TDN S $ZT="%ERROR^%FGC" G %ENDD:%TD="Q",%WH
EREND   C:%TD'="Q" %TD S %TD="Q" S $ZT="ERES^%FGC" G %ENDD
        Q
ERER    S $ZE=""
        G EREND
ERES    S $ZE="" G %END2
%LEFEG  S %PT=$V(1,0)+2
        S %NXTPTR=($V(%PT,0)#256)+(256*($V(%PT+1,0)#256))+(65536*($V(%PT+2,0)#256))
        Q
%RITLK  S %NX=$V(1020,0)#256*65536+$V(1018,0)
        Q
%LEVEL  D %LEFEG
        S %LVL(%I,"NEXT")=%NXTPTR
%LEV1   F I=1:1 D %RITLK Q:'%NX  V %NX:%S
        S %LVL(%I)=I V %NXTPTR:%S
        Q
%CNTDT  S %P=1,%FIN=$V(1022,0),J=0
%CNT1   S J=J+1,%P=$V(%P,0)#256+%P+5 G:%P<%FIN %CNT1
        S %LVL("DATA")=%LVL("DATA")+J
        Q
%BLDAR  S I=1
%BLDCT  R !,"FGC> ",J
        I J["?" S %QM=8 D ^%FGR3 G %BLDCT
        I (J="^")&(I=1) S %GLOBS(1,"NAME")="" Q
        I J="^" S I=I-1 S %GLOBS(I,"NAME")="" K %GLOBS(I,"PTR") G %BLDCT
        I $E(J,1)="^" S J=$E(J,2,$L(J))
        S %GLOBS(I,"NAME")=J Q:J=""
        S %GNAME=J,%FLAG="FGC" D %START^%GGP
        S:%GLBPTR'="" I=I+1 G %BLDCT
%SCTXT  S CTXT(1)=X
        S CTXT(2)=%J
        S CTXT(3)=%GNUM
        S CTXT(4)=%I
        S CTXT(5)=BEGT
        S CTXT(6)=%GNAME
        S CTXT(7)=%WRT
        S CTXT(8)=R
        S A1=1
        F A2=10:2:(%I*2)+9 S CTXT(A2)=%LVL(A1),CTXT(A2+1)=%LVL(A1,"NEXT")
        S CTXT((%I*2)+10)=%LVL("DATA")
        I %WRT>0 U 63:(1:12) V 6144:0:0:0:6144
        Q
%RCTXT  S X=CTXT(1)
        S %J=CTXT(2)
        S %GNUM=CTXT(3)
        S %I=CTXT(4)
        S BEGT=CTXT(5)
        S %GNAME=CTXT(6)
        S %WRT=CTXT(7)
        S R=CTXT(8)
        S A1=1
        F A2=10:2:(%I*2)+9 S %LVL(A1)=CTXT(A2),%LVL(A1,"NEXT")=CTXT(A1+1)
        S %LVL("DATA")=CTXT((%I*2)+10)
        I %WRT>0 U 63:(1:12) V 0:0:6144:0:6144
        Q
%ENDD   V %STB+74::$J*512 C 63 O 63:(1:1:1:"C") D %CNTZ V %STB+74::0
%END    D %CNTY^%TDN
%END2   C 63 K %GNAME,%FLAG,%TD,%LVL,%I,%TOTAL,%NXTPTR,%NX,%P,%PT,%FIN,%S,%GLBPTR
        K %TAPNO,%GLOBS,%GNUM,K,%J,%TFLAG,Y,%X,BEGT
        K I,J,%PROT,C,V,%A,%DEN
        K %BLK,%DEV,%GFINB,%GFINP,%MM,%NAM,%STB,%SYS,%UCI,%UCIN,%UCN,%UCNUM,X
        K %GFINQ,%STB,%TDI,%TDJ,%USMOD,%F
        Q
