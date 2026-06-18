DPSYCOPY        ;Copyright 1980 DEC ; copy system image to bootable disk
QUIT    Q
TAPENT  S %UNIT=47,SPC=0,OP="BT"
        D INIT,COPYMT,DONE
        W "magnetic tape now.",!
        G STARTSY
DISKENT D INIT,COPYDK,DONE
        W "disk or diskettes now.",!
STARTSY B 2 S $ZT="NOSTK" ZT
NOSTK   B -2 U 0:(:::::16384)
        G SYSGEN^STU
COPENT  D INIT1,COPYDK
        S $ZT=%LABEL X %LOAD
INIT    W !!!,"Now copying the system image onto your new disk,",!
        W "making it a bootable ",$ZV," system disk...",!!
INIT1   S %TYPE=$P(%D," ",2) Q
DONE    C:$D(%UNIT) %UNIT C 59 U 0 W !!,DDU," is now a bootable ",$ZV," system disk."
        W !,"You may dismount the distribution " Q
COPYDK  C 63 O 63:(2:1:1:"CZ")
        D TOANX
        D FRANX
        F BL=1:1:91 V BL:SYDDU D DWRT
        F BL=92:1:128 V BL-92+FRANX:SYDDU D DWRT
        G FIXBT
COPYMT  C 63 O 63:(2:1:1:"CZ") D TOANX
        S FM=0
        C %UNIT O %UNIT:OP U %UNIT:512
        W *5  F T=1:1:SPC D TAPRD
        I SPC S BL=2 G TAP2
        S BL=1 U %UNIT:(:0) D TAPRD U %UNIT:(:512) D TAPRD D DWRT
        S BL=2 D TAPRD D DWRT
        S BL=3
TAP2    F BL=BL:1:128 D  D DWRT
        .F T=1:1:2 U %UNIT:(:T-1*512) D TAPRD
        I 'SPC S BL=2 V BL:DDU U %UNIT:(:0) D TAPRD D DWRT
        U %UNIT W *5 C %UNIT U 0
FIXBT   S BTEN=1,FRANX=ANSTART D  Q
        .N SYDDU S SYDDU=DDU D WRTBT
WRTBT   S OFF=$S(%TY=5:1024,%TY=4:512,1:0)
        U 63:(1:2) V 2:SYDDU
        S ST=$V(44,0),BOOT=OFF F I=132:2:148 S BOOT=$V(ST+I,0)*64+BOOT
        S BL=BOOT\1024+2
        U 63:(1:1) D DREAD U 63:(2:1) S BL=BL+1 D DREAD U 63:(1:2)
        S OFF=BOOT#1024 F I=0:2:510 V I:0:$V(OFF+I,0)
        U 63:(2:1:"Z") V 0:DDU
        U 63:(1:2) F I=512:2:1022 V I:0:$V(1024+I,0)
        U 63:(1:1)
        V 510:0:%TY
        V 498:0:ANSTART#65536,496:0:ANSTART\65536*256+ANSIZE
        V 8:0:BTEN*256+($V(8,0)#256)
        I %TYPE="RK07" S TBLOC=$V(504,0) V TBLOC:0:1041
        I %TYPE="RM05" S TBLOC=$V(502,0) V TBLOC:0:19
        I $V(0,0)'=160 U 0 W !,"** Warning **  Boot block has invalid format",!
        V -16777216:DDU
        C 63 Q
DREAD   I BL<92 V BL:SYDDU Q
        V BL-92+FRANX:SYDDU Q
DWRT    S $ZT="WER" I BL<92 V -BL:DDU Q
        V -(BL-92+ANSTART):DDU Q
WER     B 1 U 0 W "! Error trying to write block number ",BL," on ",DDU,!
STOP    C:$D(%UNIT) %UNIT C 63 W " -- stopping.",! ZT
TAPRD   Q:FM  U %UNIT W *6 I $ZA<128&($ZA>63) U 0 Q
        I $ZA\16384#2 S FM=1 U 0 Q
        U 0 W !,"! Tape error !",! G STOP
FRANX   U 63:(::"Z"),0 V 0:SYDDU S FRANX=$V(497,0)*65536+$V(498,0) Q
TOANX   U 63:(::"Z"),0 V 0:DDU S ANSTART=$V(497,0)*65536+$V(498,0),ANSIZE=$V(496,0)#256
        I ANSTART Q
        U 0 W !,"No V3.1 system image extension area defined." G STOP
