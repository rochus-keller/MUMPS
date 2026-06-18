%LNKMP  ;6-Mar-85 ;DSM-11 ;UTILITIES ;Link free blocks into a linked list in map blocks ;RWB
        S $ZT="LNKER^%LNKMP",%ARES=-1,ERR=0
        U 63:(1:1:"CP")
        S %DT=0
        S %M=%PTRL-(%PTRL#400)+399
        S F=%PTRL#400,%R=%M D %VALRF G:ERR %QUIT S ST=F
        S %I=1,%Z=%N-1,%M=%R-400
        S %ARES=0
        F P=1:1 Q:%I=(%LVL+1)  S %M=%M+400 Q:%M>%LAST  D %MAPRO Q:ERR
        I (%M>%LAST)!ERR G %QUIT
        S %ARES=1
        S F=%DATL#400,%R=%DATL-F+399
        S %Z=-2
        I (%R=%M)&(F'>H) S F=H+1
        I %R<%M S %R=%M,F=0
        S:%R=%M ERR=-1
        D %VALRF
        I ERR G %QUIT
        E  S ERR=0
        I %R>%LAST S %ARES=0 G %QUIT
        S %LVL(%LVL,1)=%R,%LVL(%LVL,2)=F
        V %R:%S
        I %R=%M S P=$V(800,0),V=F
        E  S P=F,V=0
        S ST=F,%M=%R
        D %MAPRO
        I (('V)&ERR)!(ERR>1)) G %QUIT
        E  S ERR=0
        V %M:%S,800:0:P,802:0:V,-%M:%S
        F P=1:1 Q:'%N  S %M=%M+400 Q:%M>%LAST  D %MAPRO Q:ERR
        I (%M>%LAST)!ERR G %QUIT
        S %LVL("LAST")=%M
        S %ARES=2
%QUIT   U 63:(1:1:"C")
        I %ARES<2 D CLEAN
        K %M,%I,%Z,P,%R,H,J,K,L,ST,%DT,V,Q
        U 0
        Q
%MAPRO  V %M:%S
        S Q=%N
        S:($V(830,0)=12345)&($V(828,0)=54321) ERR=ERR+1
        I '$V(1022,0) V 800:0:-2 V -%M:%S Q
        F J=ST:1 Q:'($V(J*2,0))!(J=399)
        I J=399 V 800:0:-2 V -%M:%S Q
        S H=J,%N=%N-1 D:%N=%Z %UPDT G:%DT %MEND V 800:0:J
        F L=1:1 Q:'%N  D  Q:K=399  S %N=%N-1 V H*2:0:K S H=K D:%N=%Z %UPDT G:%DT %MEND
        .F K=H+1:1 Q:(K=399)!'($V(K*2,0))
%MEND   V H*2:0:-2 V 1022:0:$V(1022,0)+%N-Q,830:0:12345,828:0:54321,-%M:%S S ST=0,%DT=0
        Q
%VALRF  V %R:%S
        S:($V(830,0)=12345)&($V(828,0)=54321) ERR=ERR+1
        I $V(1022,0)'>0 G %VAL1
        F F=F:1 Q:(F'<399)!('$V(F*2,0))
        Q:F<399
%VAL1   F %R=%R+400:400 Q:%R>%LAST  V %R:%S S:($V(830,0)=12345)&($V(828,0)=54321) ERR=ERR+1 Q:$V(1022,0)>0
        Q:%R>%LAST
        F F=0:1 Q:'$V(F*2,0)!(F'<399)
        I F'<399 G %VAL1
        Q
%UPDT   I %I=%LVL S %DT=1 S %I=%I+1 Q
        S %LVL(%I,1)=%M,%LVL(%I,2)=H,%I=%I+1
        I (%I=%LVL)&(%LVL(%I-1)=1) S %DT=1 S %I=%I+1 Q
        S %Z=%Z-%LVL(%I-1)
        I %I=%LVL S %Z=%Z+1
        Q
LNKER   S FGZA=$ZA,FGZE=$ZE U 63:(1:1:"C") D DISPER^%TDN G %QUIT
CLEAN   U 63:(1:1) V %STB+74::$J*512
        C 63 O 63:(1:1:1:"CP")
        V %STB+74::0
        F A=399:400 Q:A>%LAST  D
        .V A:%S S C=0
        .Q:($V(830,0)'=12345)!($V(828,0)'=54321)
        .V 830:0:0,828:0:0
        .S E=$V(800,0) S C=1 I E'=65534 F G=1:1 V 1022:0:$V(1022,0)+1 S F=$V(E*2,0) V E*2:0:0 Q:F=65534  S E=F
        .V 800:0:0
        .S E=$V(802,0) I E S C=1 I E'=65534 F G=1:1 V 1022:0:$V(1022,0)+1 S F=$V(E*2,0) V E*2:0:0 Q:F=65534  S E=F
        .V 802:0:0
        .S E=$V(804,0)#256,%FNM=""
        .I E F G=1:1 S %FNM=%FNM_$C(E) S E=$V(804+G,0)#256 Q:'E
        .I C V -A:%S
        U 63:(1:1:"C")
        K E,G,F,C,A
        Q
