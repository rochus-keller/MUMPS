DPUTILOD        ;
QUIT    Q
COPENT  S $ZT=%LABEL X %LOAD
DISKENT ZS DPUTILOD D ULOD S $ZT="SDPERR^DPUTILOD"
        U 59 F I=1:1 R N Q:N="*TM*"  I $ZA<0 G SDPERR
SDPROU  X "F I=1:1 U 59 R N Q:N=""*TM*""  ZL  ZS @N U 0 W:K=1 ! W ?K,N S K=K+10#80"
        R N I N?1"END OF VOLUME "1.N D MOUNT G SDPROU
        I N'="START GLOBALS" G SDPERR
        U 0 W !!,"Transferring the system globals:" S K=1,NM=""
        F I=1:1 U 59 R N D:N'="*TM*"  I N="*TM*" R N G MOUSY:N="END OF GLOBALS",SDPERR:N'?1"END OF VOLUME "1.N D MOUNT
        .I $P(N,"(",1)'=NM S NM=$P(N,"(",1) U 0 W:K=1 ! W ?K,$E(NM,2,9) S K=K+10#80 U 59 K @N
        .R V S @N=V
TAPENT  ZS DPUTILOD D ULOD S $ZT=""
        U 47 F I=1:1 R N Q:$ZA\16384=1  I $ZA>127!($ZA<64) G TAPERR
        X "F I=1:1 U 47 R N Q:$ZA\16384=1  ZL  G:$ZA>127!($ZA<64) TAPERR^DPUTILOD ZS @N U 0 W:K=1 ! W ?K,N S K=K+10#80"
        U 0 W !!,"Transferring the system globals:" S K=1,NM="",$ZT="TAPERR^DPUTILOD"
        F I=1:1 U 47 R N G:N="*TM*" DONE D
        .I $P(N,"(",1)'=NM S NM=$P(N,"(",1) U 0 W:K=1 ! W ?K,$E(NM,2,9) S K=K+10#80 U 47 K @N
        .R V S @N=V
ULOD    W !,"Loading the ",$ZV," system utilities onto the system disk:",!
        K (%D,%LABEL,DDU,%TY,SYDDU,%UPG)
        S K=1 Q
MOUSY   S $ZT="MOUSYER" C 63 O 63:(:::"Z") V 0:SYDDU I $V(0,0)=160 G DONE
MOUSYER U 0 W !!,"Please re-insert installation diskette #1 in drive ",SYDDU
        R ", then press return > ",N G MOUSY
DONE    U 0 W !
        G @(%LABEL_"^DPSYCOPY")
MOUNT   S V=$P(N," ",4)
        U 0 W !!,"The end of installation diskette ",V," has been reached."
MOUNT0  I V>1 U 0 W !!,"Please remove installation diskette ",V," from drive ",SYDDU
MOUNT1  U 0 W !,"Please insert installation diskette ",V+1," in drive ",SYDDU
        R ", then press return > ",N
        S $ZT="MNTER" C 63 O 63:(:::"Z") V 0:SYDDU S N=$V(0,0) C 63
        I N=160 W !!,SYDDU," holds installation volume 1." G MOUNT1
        U 59:(0:1:SYDDU) R N U 0 I N=("START OF VOLUME "_(V+1)) S K=1 Q
        I N'?1"START OF VOLUME "1N W !,"That's not a recognizable diskette.",! G MOUNT1
        W !,SYDDU," holds installation diskette ",$P(N," ",4),! G MOUNT1
MNTER   I $ZE["<DKHER>"!($ZE["<SDPER>") U 0 W !,"Can't read from ",SYDDU,! G MOUNT1
SDPERR  ;
TAPERR  ;
        U 0 W !,$ZE,!,"Installation aborted."
H       B 0 G H
