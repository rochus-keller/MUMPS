MOUNTX  ;21-May-86 ;DSM11 ;UTILITIES ;enable DSKMAP entry ;DRS
        W !,"Add a disk to DSKMAP and a controller table."
        N  S ST=$V(44)
        S SYS=^SYS(0,"RUNNING") I SYS="" W !,"Cannot do this in baseline mode." Q
        D POSS
        I 'SG W !,"All of the disks defined in SYSGEN are already in the DSKMAP." Q
        D WHICH
        Q:%A  W !,"Adding ",DDU," (a ",DDNAME,") into the DSKMAP"
        D VIEW I '%A W ! G ^DISKMAP
        W !?5," * FAILED * due to "
        I %A=1 W "no bad block table space available." Q
        I %A=2 W "the DSKMAP entry not zeroed."
        I %A=3 W "the bit for unit ",$E(DDU,3)," already set in the controller table."
        W !,"This should never have happened." ZT $J(%A,4)
POSS    ;
        D SG
        N M S M=1 D DSK^DPBEGIN
SUBT    ;
        N DTYP,I,X S DTYP="" F I=1:1 D  Q:DTYP=""
        .S DTYP=$O(DSK(DTYP)) Q:DTYP=""  S X=$P(DSK(DTYP)," ",2)
        .I $D(SG(X)) S SG(X)=SG(X)-1,SG=SG-1 K:'SG(X) SG(X)
        .E  D
        ..W !!,X," ",$P(DSK(DTYP)," ",3),DTYP#8
        ..W " was not defined at SYSGEN, but was present at boot time."
        ..W !?5,"It is using Bad Block Table space, and it could prevent you from mounting additional disks."
        .K DSK(DTYP)
        Q
SG      N DTYP S DTYP="",SG=0 F I=1:1 D  Q:DTYP=""
        .S DTYP=$O(^SYS(SYS,"DISKTYPE",DTYP)) Q:DTYP=""  S SG(DTYP)=^(DTYP),SG=SG+SG(DTYP)
        Q
WHICH   ;
        N CONT
W1      W !,"These disks were defined in SYSGEN, but not seen at boot time:"
        W !!?10 S D="" F I=1:1 S D=$O(SG(D)) Q:D=""  W D,"  "
        W !!,"Which one do you wish to add to DSKMAP now? > " R DDNAME I "^"[DDNAME S %A=1 Q
        I DDNAME="?" W !,"Type one of the disk names on the list, or RETURN to exit without changing." G W1
        I '$D(SG(DDNAME)) W " ??" G W1
W2      W !!,"What is the disk's unit number (0-7)? > " R UNIT I "^"[UNIT G W1
        I UNIT'?1N!(UNIT>7) W !?10,"Enter the unit number, 0 to 7." G W2
        D  S CODE=$P(DDINFO," "),DDU=$P(DDINFO," ",3)_UNIT,DTYPE=$P(DDINFO," ",4) S:DTYPE=2 DTYPE=3
        .N DKNAM D DKNAM^DPBEGIN S DDINFO=DKNAM(DDNAME)
W3      ;
        D CONTRS ZT:'CONT(DTYPE)
        F I=1:1:CONT(DTYPE) I $P(CONT(DTYPE,I),"\",2)[UNIT D  G W2
        .W !,"There is already a known disk named ",DDU,"."
        .W !,"You cannot have two ",$E(DDU,1,2)," disks with the same unit number."
        .W !,"If you have changed unit number plugs since booting,"
        .W !," you may need to shutdown and reboot."
        I CONT(DTYPE)=1 S CTADR=$P(CONT(DTYPE,1),"\") S %A=0 Q
        W !!,"There are ",CONT(DTYPE)," controllers where ",DDU," could be."
        W !!,"To which controller is ",DDU," connected? (1-",CONT(DTYPE),") >" R CNUM G W2:"^"[CNUM,W3:"?"[CNUM
        I CNUM'?1N.N!(CNUM<1)!(CNUM>CONT(DTYPE)) W " ??" G W3
        S CTADR=$P(CONT(DTYPE,CNUM),"\") S %A=0 Q
CONTRS  ;
        K CONT N CT,I,U,T,N S CT=$V(ST+24) F I=1:1 D  Q:'CT
        .S U=$V(CT+10)#256,T=$V(CT+10)\256\32
        .S:'$D(CONT(T)) CONT(T)=0 S (N,CONT(T))=CONT(T)+1,CONT(T,N)=CT_"\"
        .F I=0:1:7 S:U#2 CONT(T,N)=CONT(T,N)_I S U=U\2
        .S CT=$V(CT)
        Q
CONTRS2 ;
        N CODE,CNUM,CTADR,UNM,UNS D CODE^DPBEGIN
        W !!,$E(DDU,1,2),"  controllers and disks presently include:"
        F CNUM=1:1:CONT(DTYPE) DO
        .W !,$E(DDU,1,2)," controller #",CNUM
        .S UNS=$P(CONT(DTYPE,CNUM),"\",2)
        .I UNS="" W "  knows of no disks attached to it."
        .E  W "  has these disks: " F UNM=0:1:7 I UNS[UNM DO
        ..W !?5,$E(DDU,1,2),UNM,"  "
        ..N T S T=$V(DTYPE*8+UNM*4+DSKMAP)#256
        ..I T=0 W "(no disk is ^MOUNTed here)"
        ..E  W $P(CODE(T),",",2)
        Q
VIEW    ;
        N DSKMAP,ST S ST=$V(44),DSKMAP=$V(ST+224)
        N DTYPE S DTYPE=$P(DDINFO," ",4)
        N DSKOFFS S DSKOFFS=DTYPE*8+$E(DDU,3)*4
        I $V(DSKMAP+DSKOFFS)'=0 S %A=2 Q
        N BBMM D BBMM I '$D(BBMM) S %A=1 Q
        N U,UBIT S U=$E(DDU,3),UBIT=1 F I=1:1:U S UBIT=UBIT*2
        I $V(CTADR+10)\UBIT#2 S %A=3 Q
        V DSKMAP+DSKOFFS::BBMM*256+CODE,DSKMAP+DSKOFFS+2::0
        V CTADR+10::$V(CTADR+10)+UBIT S %A=0
        Q
BBMM    ;
        K BBMM N TYP,UNI,BBAVAIL,BBHI,BBLO S BBLO=255,BBHI=-1,BBAVAIL=^SYS(SYS,"MEM.ALLOC","BBTAB")+63\64
        F TYP=0:1:7 F UNI=0:1:7 DO
        .N ADD S ADD=TYP*8+UNI*4+DSKMAP
        .I $V(ADD)#256 D
        ..S BBAVAIL=BBAVAIL-3
        ..N BB S BB=$V(ADD)\256#64 S:BB>BBHI BBHI=BB S:BB<BBLO BBLO=BB
        .ZT:BBAVAIL<0  I BBAVAIL<3 S %A=1 K BBMM Q
        .S BBMM=BBHI+3 Q
        Q
