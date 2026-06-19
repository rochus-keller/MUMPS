DISMOUNT        ;UTILITIES ;DISMOUNT DISKS AND VOLUME SETS
START   S $ZT="ETRAP^DISMOUNT"
        D CHKSYS^SYSROU Q:%A
        W !,"Dismount disk volume or Volume Set:",!
        B 0 C 63 O 63::1 E  W !,"View buffer is busy." B 1 Q
        D START^%STRTAB
        K (STR) S ST=$V(44),STSIZ=$V(ST+34)#256,STBL=$V(ST+12),DTBL=$V(ST+224)
        S VS=0,N=0 F I=1:1 S N=$O(STR(N)) Q:N=""  D
        .I STR(N)="" Q
        .S VS=VS+1,S="S"_N,VS(VS)=STR(N)
        .W !,STR(N)," - mounted Volume Set ",S
        .S SP=" (",U="" F I=1:1 S U=$O(STR(N,U)) Q:U=""  W SP,$P(STR(N,U),":") S SP=", "
        .W ")"
        F D=0:1:63 S M=$V(4*D+DTBL)\16384 I M>0,M<3 D
        .S VS=VS+1,%D=$V(4*D+DTBL)#256 D %D^DPBEGIN S S=$P(%D," ",3)_(D#8)
        .S VS(VS)=S_","_D W !,S," - ",$P(%D," ",2)," unit ",D#8
        .I M=1 W " mounted for VIEW ONLY"
        .I M=2 W " mounted as a non-UCI volume"
        I 'VS W !,"There are no volumes or Volume Sets to be dismounted." G EXIT
ASK     R !!,"Dismount which ? > ",ANS I ANS="^"!(ANS="") G EXIT
        I ANS="?" G HELP
        F I=1:1:VS I ANS=$P(VS(I),",") G GOTIT
HELP    W !!,"Select one of the listed volumes or Volume Sets for dismounting."
        W !,"This list contains all of the currently mounted disks except"
        W !,"those that are part of set S0, the 'system' Volume Set."
        W !,"You cannot dismount the system Volume Set."
        G ASK
GOTIT   B 0 W !,"Attempting to dismount ",ANS,"..."
        D TYPES^DPBEGIN
        I ANS'?1"D"1U1N G STR
        S TU=$P(VS(I),",",2)
        S %DT=4*TU+DTBL
        I $V(%DT)\16384=2 S STR=-1 G STR1
VIEW    V %DT+2::0,%DT::$V(%DT)#16384
        S TYU=TU D NOBB
        W " -- ",ANS," dismounted." G DONE
STR     F I=1:1 Q:'$D(STR(I))  I ANS=STR(I) S STR=I Q
        S ADR=STSIZ*STR+STBL
STR1    D QUIET^SYSWAIT
        I %FAIL'=0 W "Important system processes still active - try again.",! G DONE
        I STR'=-1 S %JON="" F I=1:1 S %JON=$P(%JO,",",I) Q:%JON=""  I $V(149,%JON)\32=STR W "Job #",%JON," is logged into ",ANS G DEND1
        I $V(ST+410)#2,$V(ST+54)#256=128,$V(ST+410)\256#2=0 S TYU=$V(ST+266)#256\4 D TYU I %ER W "Journaling" G DEND2
        I $V($V(ST+8)+2)#256=255 G SDP
        S TYU=$V($V(ST+10)+$V(ST+68)+17)\4 D TYU I %ER W "Spooling" G DEND2
SDP     F U=59:1:62 I $V($V(ST+8)+U)#256 S TYU=$V(U-59*$V(ST+232)+$V(ST+408)+9)\4 D TYU I %ER W " SDP" G DEND2
        S VTBL=$V(ST+138) I VTBL#2 G KILNOD
        F U=0:4:63 S TYU=$V(U,VTBL)\1024 D TYU I %ER V U:VTBL:0,U+2:VTBL:0
KILNOD  K VTBL
        F I="JOURNAL","SDP","SPOOL" S %SPACE=I_" SPACE" D
        .S X="" F J=1:1 S X=$O(^SYS(0,%SPACE,X)) Q:X=""  I X?1N.N D
        ..S TYU=$F(TYPES,$E(^(X,"DISK"),1,2))\3-1*8+$E(^("DISK"),3)
        ..D TYU I %ER K ^SYS(0,%SPACE,X) I %SPACE["SPOOL"&(X=1) S ^("INDEX")=1
        K %SPACE
        I STR=-1 G VIEW
        S BDB=0,S=STR*32+1,GBFBLK=$V(ST+504),GBFSTA=$V(ST+506)
        F I=1:1:$V(ST+32) S BDB=BDB+4 I $V(BDB+2,GBFSTA)#256<128,$V(BDB+3,GBFBLK)=S V BDB+2:GBFBLK:65535
        K BDB
        S SAT=$V(ADR+4)
        F I=0:1:7 I $V(STSIZ*I+STBL+4)>SAT S SAT($V(STSIZ*I+STBL+4))=I
        S NXT=""
NEXT    S NXT=$O(SAT(NXT))
        I NXT="" K SAT,NXT,OLDMM,SIZ G SETSAT
        S OLDMM=$V(SAT(NXT)*STSIZ+STBL+4),SIZ=$V(0,OLDMM)+16+511\512
        V 0:SAT:0:OLDMM:SIZ*64
        V SAT(NXT)*STSIZ+STBL+4::SAT S SAT=SAT+SIZ
        G NEXT
SETSAT  S MXSAT=0 F I=0:1:3 I $V(STSIZ*I+STBL+4)>MXSAT,I'=STR S MXSAT=$V(STSIZ*I+STBL+4)
        V ST+356::$V(0,MXSAT)+511\512+MXSAT
REMSTR  S D=$S($V(ADR+6)>49152:$V(ADR+6)-49152,1:1)
        F I=1:1:D S TYU=$V(3*I+ADR+7)#256\4 V TYU*4+DTBL+2::0,TYU*4+DTBL::$V(TYU*4+DTBL)#16384 D NOBB
        F I=0,4:2:STSIZ-2 V ADR+I::0
        D LOAD^REPTAB
        I $V(ST+276) D UPDTAB^TRANTAB
        W !,"Volume Set ",ANS," is dismounted."
        S SCM="MIS" D ALINKS^DDPSRV
        G DONE
DEND2   W " active on disk"
DEND1   W " - cannot dismount"
DEND    W !
DONE    D RELSYS^SYSWAIT
EXIT    C 63 K ANS,ST,STBL,DTBL,STR,ADR,%JO,%ER
        B 1 Q
TYU     I $D(TU) S %ER=TYU=TU Q
        S %ER=0 F I=1:1:$S($V(ADR+6)>49152:$V(ADR+6)-49152,1:1) I TYU*4=($V(I-1*3+ADR+10)#256) S %ER=1 Q
        Q
NOBB    V 0:$V(4*TYU+DTBL+1)#64+$V(ST+86):0 Q
ETRAP   W !,$ZE G DONE
