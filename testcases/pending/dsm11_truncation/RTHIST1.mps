RTHIST1 Q  ; ROUTINE TO LOG HISTOGRAM
START   K (ST,SZ,MM,TIM,TIMS,SUB,CONF,LAB) S $ZT="ERROR"
        F RUNS=1:1:TIMS S SUB=SUB+1 S ^RTH=SUB D NEXT I ^RTH=0 Q
EXIT    V ST+278::0 S ^RTH=0 H
NEXT    D ONEJOB S MSG="Histogram #"_^RTH_" started" D SNDMES
        F I=4:2:SZ-2 V I:MM:0
        V 0:MM:SZ-18+49152,2:MM:144+49152
        F I=ST+236:2:ST+258 V I::0
        F I=ST+432:2:ST+442 V I::0
        V ST+218::0,ST+220::0,ST+222::0
        V ST+270::0,ST+272::0,ST+274::0
        V ST+280::0,ST+282::$V(ST+283)*256
        V ST+492::$V(ST+492)#256
        F I=ST+494:2:ST+500 V I::0
        S D1=$V(ST+444)
        I D1 S D=$V(0,D1) F I=1:1 Q:'D  V 50:D:0,52:D:0,54:D:0,56:D:0 S D=$V(0,D)
        S STIME=$H
        V ST+278::MM D CLRJOB H TIM*60
STORE   D ONEJOB V ST+278::0
        S ^RTH(SUB,"ETIME")=$H,^("STIME")=STIME,^("CONF")=CONF,^("LABEL")=LAB
        S ^("IDLE")=$V(ST+498)#256*65536+$V(ST+496)
        S ^("TOTAL")=$V(ST+499)*65536+$V(ST+500)+^("IDLE")
        S ^("SWAPINS")=$V(ST+493)*65536+$V(ST+494)
        S ^("READS")=$V(ST+244)#256*65535+$V(ST+242),^("WRITES")=$V(ST+245)*65536+$V(ST+246)
        S ^("GLOREF")=$V(ST+238)#256*65535+$V(ST+236)
        S ^("LOGRD")=$V(ST+239)*65536+$V(ST+240),^("GLOSET")=$V(ST+250)#256*65536+$V(ST+248)
        S ^("LOGWT")=$V(ST+251)*65536+$V(ST+252)
        S ^("TOTRD")=$V(ST+256)#256*65536+$V(ST+254)
        S ^("WTSYNC")=$V(ST+257)*65536+$V(ST+258)
        S ^("TTYOUT")=$V(ST+220)#256*65536+$V(ST+218)
        S ^("TTYIN")=$V(ST+221)*65536+$V(ST+222)
        S ^("TRYLAST")=$V(ST+272)#256*65536+$V(ST+270)
        S ^("GOTLAST")=$V(ST+273)*65536+$V(ST+274)
        S ^("MAPROU")=$V(ST+282)#256*65536+$V(ST+280)
        S ^("ROUREF")=$V(ST+434)#256*65536+$V(ST+432),^("GLOKIL")=$V(ST+435)*65536+$V(ST+436)
        S ^("ALLOC")=$V(ST+440)#256*65536+$V(ST+438),^("DEALL")=$V(ST+441)*65536+$V(ST+442)
        I D1 S D=$V(0,D1) F I=1:1 Q:'D  S ^("DDPOUT"_I)=$V(52,D)*65536+$V(50,D),^("DDPIN"_I)=$V(56,D)*65536+$V(54,D),^("DDPNAM"_I)=$
V(10,D),D=$V(0,D)
        S ADD=80 F I=0:1:7 S ^RTH(SUB,"DISK",I,"READ")=$V(ADD+2,MM)*65536+$V(ADD,MM),^("WRITE")=$V(ADD+6,MM)*65536+$V(ADD+4,MM),ADD=
ADD+8
        F I=2:1 S NODE=$P($T(NODES),";;",I) Q:NODE=""  S ^RTH(SUB,NODE)=$V(I-1*4+10,MM)*65536+$V(I-1*4+8,MM)
        F ADD=144:18:$V(2,MM)-49154 D NODE
        S MSG="Histogram #"_^RTH_" complete" D SNDMES,CLRJOB Q
NODE    S RTN="",U=$V(ADD,MM)#32,V=$V(ADD,MM)\32#8
        I '(U+V) S U=$V(ADD+14,MM),V=$V(ADD+16,MM),UCI=$C(U\2048#32+64,U\64#32+64,U\2#32+64)_","_$C(V\2048#32+64,V\64#32+64,V\2#32+6
4)
        E  S UCI=$ZU(U,V)
        I $V(ADD+9,MM)=0 S TY="GLB" G GLOB
        S TY="RTN" F I=1:1:8 S C=$V(ADD+I,MM)#256 Q:C=255!('C)  S RTN=RTN_$C(C)
        S:RTN="" RTN="$$NULROU" G NODE1
GLOB    F I=1:1:8 S C=$V(ADD+I,MM)#256,RTN=RTN_$C(C\2) Q:C#2=0
NODE1   S ^RTH(SUB,TY,UCI,RTN)=$V(ADD+12,MM)*65536+$V(ADD+10,MM) Q
ERROR   S MSG="Fatal error encountered: "_$ZE D SNDMES,CLRJOB G EXIT
ONEJOB  V ST+74::$J*512+($V(ST+74)#256) Q
CLRJOB  V ST+74::$V(ST+74)#256 Q
SNDMES  ZU $V($V(44)+346)#256:(:::::32) W !
        S %TM=$P($H,",",2)
        S %M=%TM#3600\60,%S=%TM#60,%TIM=%TM\3600_":"_(%M\10)_(%M#10)
        S %TIM1=%TIM,%A=$S(%TM<43200:"AM",1:"PM") I $P(%TIM,":",1)>12 S %TIM1=$P(%TIM,":",1)-12_":"_$P(%TIM,":",2,99)
        S %TIM1=%TIM1_" "_%A
        W %TIM,?8,"Histogram Logger ",$J," - ",MSG Q
NODES   ;;JOBS;;SHORTQ;;DKRBQ;;IORQ;;WAIT1Q;;WAIT2Q;;WAIT3Q;;WAIT4Q;;GLOBQ;;GLOLKQ;;JRNQ;;GLOBAL;;GLOVF;;NOROOM;;%GLOCK;;%GLWAIT
