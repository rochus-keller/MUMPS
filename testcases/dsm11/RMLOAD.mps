RMLOAD  ;23-Jun-83 ;UTILITY ;ROUTINE MAP ;LOADS A ROUTINE SET ;JHM
        D CHKRM^RMBLD Q:%A
        W !,"Load a Routine Set into Memory",!
Q0      S SETNAM="",EXTH=0 D GETNAM^RMBLD Q:%A
        I '$D(^SYS(0,"ROUTINE MAP",SETNAM)) W !,SETNAM," is not defined",! G Q0
LOAD    S ST=$V(44),ROUMAP=$V(ST+38)
        S $ZT="KILPRG^RMLOAD"
        O 63::1 E  W !,"View Device 63 unavailable, can not proceed",! G EXIT
        S ROUNUM=+^SYS(0,"ROUTINE MAP",SETNAM)
        S %UCI=$P(^(SETNAM),",",2),%SYS=$P(^(SETNAM),",",3)
        D GETUCN^RMBLD
        I 'UCN W !,"Mapped Routine Set: ",SETNAM," - not loaded",! G EXIT
        S ROUEND=$V(ST+216)+ROUMAP
        F ENT=0:1:63 G:$V(ENT*8,ROUMAP)=UCN DUPUCN I '$V(ENT*8,ROUMAP) G LOADIT
        D NOROOM G EXIT
LOADIT  S MMADR=$V(ENT*8+4,ROUMAP)
        S MMNAM=MMADR*64+(ROUNUM+1\2*2*2)+63\64
        S ROUSTR=MMNAM*64+(ROUNUM+1\2*2*8)+63\64
        I ROUSTR+2'<ROUEND D NOROOM G EXIT
        V ENT*8+6:ROUMAP:MMNAM
        S RNAM="",RNUM=0 W !,"Loading Mapped Routine set: ",SETNAM,!!
LOOP    S RNAM=$O(^SYS(0,"ROUTINE MAP",SETNAM,RNAM)) G:RNAM="" DONE
LOOP1   S RSIZE=$P(^[%UCI,%SYS] (RNAM),",",3),RBLK=$P(^(RNAM),",",4)
        S REND=ROUSTR*64+RSIZE+63\64
        I REND'<ROUEND D NOROOM G DONE
        I RSIZE>8190 D TOOBIG G LOOP
        S STR="S"_(UCN\32),MPTR=0 V RBLK:STR
        S BPTR=$V(1,0)+2+3+1\2*2+2
NXTBLK  I RSIZE+BPTR>1014 S BYTES=1014-BPTR
        E  S BYTES=RSIZE
        V MPTR:ROUSTR:BPTR:0:BYTES
        S MPTR=MPTR+BYTES,BPTR=0,RSIZE=RSIZE-BYTES
        S RBLK=$V(1016,0)#256*65536+$V(1014,0)
        I RBLK V RBLK:STR G NXTBLK
        W ?$X+9\10*10,RNAM W:$X>70 ! S RNUM=RNUM+1
        V RNUM-1*2:MMADR:ROUSTR
        S RN=RNAM I $L(RN)#2 S RN=RN_$C(255)
        F I=0:2:$L(RN)-2 V RNUM-1*8+I:MMNAM:$A(RN,I+2)*256+$A(RN,I+1)
        F I=I+2:2:6 V RNUM-1*8+I:MMNAM:65535
        S ROUSTR=REND G LOOP
DONE    I RNUM#2 S RNUM=RNUM+1 F I=0:2:6 V RNUM-1*8+I:MMNAM:65535
        I ENT<62 V ENT+1*8:ROUMAP:0,ENT+1*8+4:ROUMAP:ROUSTR
        V ENT*8+2:ROUMAP:RNUM,ENT*8:ROUMAP:UCN
        W !!,ROUSTR-MMADR*64," Bytes used for Routine Set ",SETNAM
        W !,ROUEND-ROUSTR*64," Bytes remain in Mapped Routine Space",!
EXIT    K PRNT,RNUM,ENT,ROUMAP,UCN,%UCI,%SYS,RNAM
        C 63
        Q
NOROOM  W !,"There is not enough space to load the remainder of this routine set." Q
TOOBIG  W !,"Routine, ",RNAM,", is greater than 8KB and can not"
        W !,"be included in the mapped routine set.",! Q
DUPUCN  W !,"A routine map already exists for ",$ZU(UCN#32,UCN\32),"."
        W !,"Only 1 routine map per UCI and VOLUME SET is allowed." G EXIT
KILPRG  I $ZE'?1"<UNDEF>LOOP1".E W !,RNAM," Deleted ... continuing",*7 S $ZT="KILPRG^RMLOAD" G LOOP
        W !,"UNEXPECTED ",$ZE Q
