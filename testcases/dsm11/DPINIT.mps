DPINIT  ;
        U 0 W !!,"To initialize, test, or format a DSM11 disk, type:",!
        W ?9,"D ^DISKPREP",!
QUIT    Q
COPENT  S SHOW=0 G BEGIN
DISKENT V SYTYU*4+$V(ST+224)::$V(SYTYU*4+$V(ST+224))#16384+(3*256)
        F I=0:2:190 V 192+I:$V(ST+86):$V(I,$V(ST+86))
TAPENT  S SHOW=1,UCB=92
BEGIN   D SYCHK,START,MOUNT
        I %UPG=3 D ANCHECK
        I %UPG=0 D INITSY
        I $D(ANSTART) D ANNEX
NXTP    S $ZT=%LABEL X %LOAD
SYCHK   F I=1:1:%B G NOTSY:%B(I)<93
        Q
NOTSY   W !,"There's a bad block before block 93, so ",DDU," can't be used as a system disk."
ABORT   W !,"Installation has failed and is now terminating.",!
        W !,"Exit",!
H       B 0 G H
START   S MM=$V(%DT+1)#64+$V(ST+86) F I=0:2:190 V I:MM:$V(BOF+I,0)
        V %DT+2::%MP
        U 63:(1:1:"CZ") V -16777216:DDU C 63 O 63
        I %UPG Q
        S LMB=399 I SHOW W !,"Now initializing ",DDU," for use as DSM-11 volume..."
INAREA  V 1022:0:399 F I=0:2:1020 V I:0:0
        V 1006:0:65535,1008:0:21845,1010:0:21845*2,1012:0:32769,798:0:65535
        S $ZT="INIER"
        F BL=%MP*400-1:-400:LMB V -BL:DDU
        I LMB>399 Q
        V 0:0:65535,1022:0:398
        I $D(UCB),UCB=1 V 2:0:65535,1022:0:397
        V -399:DDU
        I '$D(UCB) Q
        I UCB'=1 Q
        F I=0:2:1022 V I:0:0
        S BL=UCB V -BL:DDU Q
INIER   W !,"! Error:  ",$ZE,!,"  while writing relative DSM blk # "
        W BL," on this disk.",! G ABORT
INITSY  S ANSTART=98,ANSIZE=102
        C 63 O 63:(:::"Z") V 0:DDU
        V 496:0:ANSIZE,498:0:ANSTART
        V -16777216:DDU U 63:(::"C"),0 V 399:DDU
        V 1022:0:399-(98+ANSIZE)
        F I=0:2:92*2,ANSTART*2:2:ANSTART+ANSIZE-1*2 V I:0:65535
        F I=2*93:2:2*97 V I:0:257
        V -399:DDU
        F I=0:2:1022 V I:0:0
        S STR=$V(ST+12)
        F I=0:2:18 V I:0:$V(I,$V(STR+2))
        V 14:0:%SIZ-1
        V -92:DDU
        F I=0:2:18 V I:0:0
        V 1020:0:256
        V -95:DDU
        V 0:0:256,2:0:97*256+64,4:0:0,1020:0:6*256,1022:0:6
        V -96:DDU
        V 2:0:64,4:0:0,1020:0:16*256
        V -97:DDU
        D FILDIR
        Q
MOUNT   S STR=$V(ST+12)
        V STR+6::0,STR+8::%SIZ,STR+10::%TY*8+$E(DDU,3)*4
        S SAT=$V(STR+4)
        V 0:SAT:%SIZ
        F I=2:2:%SIZ+15\16*2 V I:SAT:65535
        V %DT::$V(%DT)#16384+32768+16384
        V 14:$V(STR+2):$S(%SIZ<$V(ST+234):$V(ST+234)-1,1:%SIZ-1)
        F I=1:1:$V(ST+32) I $V(4*I+2,$V(ST+506))#256<128 V 4*I+2:$V(ST+504):65535
        V ST+56::$V(ST+57)*256+(%TY*8+$E(DDU,3)*4)
        Q
FILDIR  V 0:0:256,2:0:94*256+66,4:0:0,1020:0:6*256,1022:0:6
        V -93:DDU
        V 2:0:66,4:0:0,1020:0:64*256
        V -94:DDU
        Q
ANCHECK U 63:(::"CZ") V 0:DDU S ANSTART=$V(497,0)*65536+$V(498,0),ANSIZE=$V(496,0)#256
        I ANSTART>0 Q
        S ANSIZE=102
        K START F MAP=0:1:%MP-1 V MAP*400+399:DDU D  I $D(START) Q
        .I $V(1022,0)'<ANSIZE,$V(1006,0)=65535,$V(1008,0)=21845,$V(1010,0)=(2*21845),$V(1012,0)=32769 D
        ..F I=0:2:399-ANSIZE*2 I '$V(I,0) S START=I D  I $D(START) Q
        ...F I=START:2:ANSIZE-1*2+START I $V(I,0) K START Q
        I '$D(START) U 0 W !,"Can't get 102 contiguous blocks for upgrade." H
        F I=START:2:ANSIZE-1*2+START V I:0:65535
        V 1022:0:$V(1022,0)-ANSIZE,-(MAP*400+399):DDU
        S ANSTART=MAP*400+(START/2) K START,MAP Q
ANNEX   U 63:(1:1:"CZ"),0
        V 0:DDU
        V 498:0:ANSTART#65536
        V 496:0:ANSTART\65536*256+ANSIZE
        V -16777216:DDU
        K ANSIZE,ANSTART Q
