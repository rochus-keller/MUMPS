STU2    Q  ;STARTUP PART 2, MOUNT DISKS, SET UP MISC. DEVICES
START   B 0 O 63 O 1 U 1 W "Memory re-configured",! S ST=$V(44)
        V 0:$V(ST+374):$V(ST+378),2:$V(ST+374):0
        S ID=^SYS(0,"RUNNING")
        F I="SDP","SPOOL","JOURNAL" K ^SYS(0,I_" SPACE")
        F I="SDP","SPOOL","JOURNAL" S ^SYS(0,I_" SPACE","INDEX")=1
GC      I $V(ST+364)+$V(ST+380) H 1 G GC
        I ^SYS(ID,"OPTIONS","USRDRV")="Y" D
        .S USRMM=$V(ST+146),STRT=$V(128,USRMM),SIZ=^SYS(ID,"MEM.ALLOC","USRDRV")
        .I SIZ>8190 S SIZ=8190
        .V STRT:USRMM:SIZ-STRT,STRT+2:USRMM:0,SIZ:USRMM:0
        D TYPES^DPBEGIN
        S DDU=$P(TYPES,",",$V(ST+56)\32#8+1)_($V(ST+56)\4#8)
        S BBOF=3,BBSIZ=^SYS(ID,"MEM.ALLOC","BBTAB")+63\64
        F D=$V(ST+224):4:$V(ST+224)+255 I $V(D),'$V(D+1) D
        .I BBOF+3>BBSIZ W !,"Not enough bad block table space.  Re-boot and run SYSGEN",!,"to include ALL existing disks in your configuration.",! F I=1:1 H 0
        .V D::$V(D)#256+(BBOF*256) S BBOF=BBOF+3
        S (STR,STMAP)=0 D START^MAPMOUNT I %A W !,"Mount failed, startup aborted!" Q
        S A=$V(ST+358),B=$V(ST+132)-$V(ST+28)*64+8192
        F I=A:2:B-1 V I::0
        S DDPLNS=^SYS(ID,"DDP","LINES")
        G DEVS:'DDPLNS S DDB=^SYS(ID,"OPTIONS","SDP")="Y"*4*$V(ST+232)+$V(ST+408)
        S DDPBF=^SYS(ID,"MEM.ALLOC","DDP BUFFERS")
        S LINE=0,IROU=$V(ST+424)
        F I=0:2:DDPBF\512-4 V I:$V(ST+448):I+2*256+I+1
        V ST+452::255*256
        V ST+454::DDPBF\512*256+($V(ST+454)#256)
        V I+2:$V(ST+448):255*256+I+3
        S MC(0)=9,MC(1)=43,MC(2)=256
        F D=DDB+4:$V(ST+384):$V(ST+384)*DDPLNS+DDB+4-1 D  S LINE=LINE+1
        .S V3=^SYS(ID,"DDP","LINES",LINE,"V3"),NO=^("CONTROLLER NUMBER"),S=^("SERVICE"),CNT=^("CONTROLLER"),%OD=^SYS(ID,"CONTROLLER",CNT,NO,"CSR") D ^%OD S CSR=%OD
        .S %OD=^("VECTOR") D ^%OD S VEC=%OD
        .V VEC::D-4,VEC+2::192 I CNT="DMC11" V VEC+4::D-4,VEC+6::192,VEC+2::193
        .V D+18::VEC
        .V D+14::$V(D+15)*256+NO
        .V D+16::$A($S(CNT="DMC11":"M",CNT="DEUNA":"E",CNT="DEQNA":"H",1:"X"))*256+$A("X")
        .F R=0:1:2 V R*2+D+20::MC(R)
        .V D-4::2207,D-2::IROU,D::CSR
        .V D+2::D+$V(ST+384) V:$E(S)="O" D+4::8
        .V D+6::V3="Y"*256+LINE
        .I CNT="DMC11" V D+12::^("PRIMARY")="N"*2+(^("HALF DUPLEX")="Y"*4)
        .V D+8::$S(CNT="DEQNA":4,CNT="DMC11":0,1:2)
        .V D+10::$V(ST+446)+(DDPBF+63\64+(LINE*2))
        .V D+12::255*256+$V(D+12)
        S RV=$V(ST+444) V D+2::0,ST+422::DDB,0:RV:0,10:RV:1
        V 26:RV:0,28:RV:3*256 F R=30:2:48,50:2:60,318:2:830 V R:RV:0
        F R=62:2:316 V R:RV:65535
        F R=0:1:2 V R*2+4:RV:MC(R)
        F I=$V(ST+450):1:$V(ST+38)-1 V 0:I:0
DEVS    ;
        D SETYP^MMD S MUUNIT=0 F I=^SYS(ID,"MT")-1:-1:0 D
        .S J=^SYS(ID,"MT",I,"TYPE"),MTT=$S(TMTYP[J:0,RHTYP[J:2,MUTYP[J:6,T81TYP[J:8,1:4)
        .S %OD=^SYS(ID,"MT",I,"CSR") D ^%OD S MTCSR=%OD
        .S %OD=^SYS(ID,"MT",I,"VECTOR") D ^%OD S MTVEC=%OD
        .S DDB=$V(ST+22)+(I*$V(ST+298))
        .V MTVEC::DDB,MTVEC+2::192
        .V DDB+4+30::MTCSR,DDB+4+32::$V(DDB+4+26)\256*256+MTT
        .V DDB+74::MTCSR+2,DDB+76::MTVEC
        .I $D(^("DEFAULT CODE")) V DDB+4+20::^("DEFAULT CODE")*256
        .S MUUNIT=MUTYP[J+MUUNIT
        K MTT,%OD,MTCSR,MTVEC,DDB,SIZ,STRT,USRMM,MC
        F I=1:1:10 I $D(^SYS(ID,"TIED TERMINAL TABLE",I,"UCI")) S PG=I-1*4+ST+318 V PG::$E(^("VSET"),2)*32+^("UCI")*256+^("PARTITION SIZE"),PG+2::$A(^("ROUTINE NAME"),2)*256+$A(^("ROUTINE NAME"))
        I ^SYS(ID,"OPTIONS","SDP")="Y" S DEV=59,N=4 D AVAIL
        I ^SYS(ID,"OPTIONS","JOBCOM")="Y" S DEV=224,N=2*^SYS(ID,"JOBCOM","CHANNELS") D AVAIL
        S DEV=47,N=^SYS(ID,"MT") D AVAIL
        K DEV,N,D G START^STU3
AVAIL   S D=$V(ST+8)+DEV F I=1:1:N D ZBYTE S D=D+1
        Q
ZBYTE   I D#2 V D-1::$V(D-1)#256 Q
        V D::$V(D)\256*256 Q
FATER   W !," -- Halting.",!!
        Q
