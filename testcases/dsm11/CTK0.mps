CTK0    Q  ; DB ;NOV80;CARETAKER MAIN LOOP
LOOP    I $V(ST+360)\2#2 ZU $V(ST+346)#256:(:::::32) W !!,*7,"*** System disk is off line  ***",! D CLR H TIM G LOOP
        I $V(ST+162)\32768#2 D ZUSE^CTKUTL W *7," DU fatal Controller error, D ^KTR for full report ***",! D  H TIM G LOOP
        .D GETH^CTKUTL S ^SYS(0,"ERROR","DU",+CURH,$P(CURH,",",2))="CONTROLLER ERROR"_";"_$V(ST+162) V ST+162::0
        I $V(ST+360) S ERR=$V(ST+360) D ZUSE^CTKUTL,JRN^CTK2:ERR#2,RDK^CTK2:ERR\16#2,HDK^CTK2:ERR\32#2,DKRES^CTK2:ERR\128#2,DBOVF^CTK2:ERR\64#2,CLR^CTKUTL
        F DEV=-1:0 S DEV=$N(LP(DEV)) Q:DEV=-1  I $V($V(ST+8)+DEV)#256 ZU DEV I $ZA\32#2 D:$ZA#2 LPER^CTK2 ZU DEV:(::::1)
        I $V(ST+204)#8\2 D LOG^CTK1
NX      I JCDEV U JCDEV R P:0 I  G GER:P=$C(2),NX
        I $D(^SYS(0,"UNATTENDED BACKUP TIME")) S BTIM=^("UNATTENDED BACKUP TIME") I BTIM'="",+BTIM'>+$H,$P($P(BTIM,";",1),",",2)'>$P($H,",",2) ZJ STR^BACKUP
        S ^SYS(0,"$HLAST")=$H
TEST    S $ZT="ERR" I $V(ST+204)\8#2 H TIM G LOOP
        H
CLR     V ST+360::$V(ST+360)-($V(ST+360)\2#2*2) Q
DUERR   I  D GETH^CTKUTL S ^SYS(0,"ERROR","DU",+CURH,$P(CURH,",",2))="CONTROLLER ERROR"_";"_$V(ST+162) V ST+162::0
        Q
GER     R PN S H=+PN I '$D(^%ER(H)) S ^%ER(H)=1
        S ERR=^(H),I=1 S:ERR'>MAXERR ^(H)=ERR+1
        I ERR=MAXERR ZU $V(ST+346)#256:(:::::32) W !!,*7,"***  DSM error limit of ",ERR," reached !  D ^%ER to investigate." U JCDEVG1      R Q
G2      I Q="|" S:ERR'>MAXERR ^%ER(H,ERR)=PN K P,PN,H,ERR,Q,I G NX
        R P I P'="=" S Q=P G G2
        R P S:ERR'>MAXERR ^%ER(H,ERR,"REF",I)=Q,^%ER(H,ERR,"DAT",I)=P,I=I+1 G G1
ERR     S ZE=$ZE,$ZT="ERR2" ZU $V(ST+346)#256:(:::::32) W !!,ZE
        I ZE["DKHER" S MPMS=$V(ST+205)*65536+$V(ST+206) I MPMS W " at block ",MPMS," on ",$C($V(ST+208)#256),$C($V(ST+209)),$C($V(ST+210)#256+48)
        G TEST
ERR2    I $V(ST+204)\8#2 H TIM G ERR
        H
