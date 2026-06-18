MAPMOUNT        ;ROUTINES USED WHILE MOUNTING A DISK
        W !,"To mount a disk, type  D ^MOUNT",!
        W "To dismount a disk, type   D ^DISMOUNT",!!
        Q
START   K MPS,UNS S ST=$V(44),LABEL=512,STRTAB=$V(ST+34)#256*STR+$V(ST+12)
        I STMAP'=0 D MNTER W " - Volume must start at map 0",! D EXIT^MAPM1 Q
        S DTBL=$V(ST+224)
        D READ I %A D MNTER W " - Volume 1 not readable" D EXIT^MAPM1 Q
        I STR<0,S'=%LB D MNTER W !,"Volume Label expected was: ",LBL,!,"Volume Label found was:    ",S D EXIT^MAPM1 Q
        I STR<0 S VOLS=1,(MPS,MPS(1))=$V(812,0),STNAM="SDP DISK" D  G MAPS
        .D %DDU^DPBEGIN S UNS(1)=%D
        .W !!,"Mounting ",DDU," as a non-UCI volume with "
        I STR=0 S (STNAM,VOLNAM)=$E(S,1,3)
        I S'=(VOLNAM_1) W !,DDU," not volume 1 of ",VOLNAM S %A=1 D EXIT^MAPM1 Q
        S CODE=$V(LABEL+392,0)
        S MPS=0 S VOLS=$V(LABEL+401,0)
        F I=1:1:VOLS D
        .S MPS(I)=$V(4*(I-1)+LABEL+404,0),MPS=MPS+MPS(I)
        .S %D=$V(4*(I-1)+LABEL+402,0)#256 D %D^DPBEGIN S UNS(I)=%D
        S SATMM=$V(ST+356)
        I SATMM-$V($V(ST+12)+4)*64+(MPS+7\8)+2>$V(ST+394) W !,"SAT space exceeded!!",! S %A=1 D EXIT^MAPM1 Q
        V 0:SATMM:MPS F I=2:2:MPS+15\16*2 V I:SATMM:65535
        W !!,"Mounting ",STNAM," as Volume Set number S",STR
MAPS    D MAPS^MAPM1
        Q
READ    S $ZT="ERR" U 63:(::"Z") V 0:DDU U 63:(::"C"),0 I STR'<0 S A=394,L=4
        E  S A=304,L=22
        S S="" F I=1:1:L S S=S_$C($V(LABEL+A+I-1,0)#256)
        S %A=0 Q
ERR     U 63:(::"C"),0 S %A=1 Q
MNTER   U 0 W !!,"Fatal error mounting ",DDU S %A=1 Q
SDVAL   S %VALTAB=$V($V(44)+138) G SDDON:'%VALTAB
        F %I=0:4:63 I $V(%I,%VALTAB)=0 G SPACE
        W !," ! (Current SDP validation table full -- contains 16 entries..."
        W !," No room for "
        W:MAPS>1 "maps ",MAP," thru ",MAP+MAPS-1,!," These maps"
        W:MAPS=1 "map ",MAP,!," This map" W " will not be accessible)",!
SPACE   V %I:%VALTAB:TYU*1024+MAPS,%I+2:%VALTAB:MAP
SDDON   K %VALTAB,%I Q
