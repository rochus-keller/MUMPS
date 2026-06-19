MAPM1   ;19-Apr-85 ;DSM11 ;Mounting of disks ;Split off from mapmount ;RWB
MAPS    S PM=0,VOL="",TOTFRE=0
VOLMOU  S VOL=$O(MPS(VOL)) I VOL'="" D  G:%A EXIT G VOLMOU
        .S TY=$P(UNS(VOL)," ",3)
        .I VOL=1 S U=$E(DDU,3) G GOTU
        .S D=32*$P(UNS(VOL)," ",4)+DTBL,C=$P(UNS(VOL)," ")
        .F U=0:1:7 I $V(U*4+D)#256=C,$V(U*4+D+1)<64 S DDU=TY_U D READ I %A=0,$C($V(LABEL+302,0)#256)="M"!$V(LABEL+303,0),S=(VOLNAM_VOL),$V(LABEL+392,0)=CODE G GOTU
        .D MNTER W !,"Can't find volume ",VOL," of ",STNAM
ER      .S %A=1 Q
GOTU    .S VOLS(VOL)=$P(UNS(VOL)," ",4)*8+U*4
        .I STR'<0 W !,"Volume ",VOL," on ",DDU," has "
        .S A=$V(DTBL+VOLS(VOL)+1)#64
        .V DTBL+VOLS(VOL)+2::$V(LABEL+300,0)
        .F I=0:2:190 V I:$V(ST+86)+A:$V(LABEL+I,0)
        .I STR'<0,VOL=1 V $V(LABEL+400,0)*65536+$V(LABEL+398,0):DDU F I=0:2:1022 V I:$V(STRTAB+2):$V(I,0)
        .S FREE=0,CT=0,PTY=""
        .K %GNAME S M9=0
        .F M=0:1:MPS(VOL) D
        ..S NTY="" G SEE2:M=MPS(VOL)
        ..D MAPRD I %A W !,"-- Error reading" G WRNUM
        ..G NOTMP:$V(1006,0)'=65535!($V(1012,0)'=32769) S A=$V(1008,0)
        ..I A=56173 S NTY="SPOOL" G SEE
        ..G NOTMP:A+$V(1010,0)'=65535 I A=43690 S NTY="SDP" G SEE
        ..I A=13107 S NTY="JOURNAL" G SEE
        ..S V22=$V(1022,0) G OK:V22<400
        ..S V22=0 F IB=0:2:798 I '$V(IB,0) S V22=V22+1
        ..V 1022:0:V22,-(M*400+399):DDU
OK      ..I V22 S FREE=FREE+V22 G SEE2
SEE     ..G:STR<0 SEE2 D CLNUP S SATOF=PM+M\16*2+2,BIT=1 F IB=1:1:PM+M#16 S BIT=BIT*2
        ..V SATOF:SATMM:$V(SATOF,SATMM)-BIT
SEE2    ..I NTY=PTY Q:PTY=""  I $V(990,0)#256=0 S CT=CT+1 Q
        ..G NEWSP:PTY="" S SP=PTY_" SPACE" D GETI
        ..V MSAV*400+399:DDU S %JNAM=""
        ..F J0=990:1 S J1=$V(J0,0)#256 Q:'J1  S %JNAM=%JNAM_$C(J1)
        ..S ^SYS(0,SP,INDEX,"DISK")=DDU,^("START")=START,^("END")=M-1*400+399
        ..I %JNAM="" D RENAM
        ..G NOTJ:PTY'="JOURNAL"
        ..F J0=1:1:INDEX-1 I $D(^SYS(0,SP,J0,"NAME")),^("NAME")=%JNAM D SAMNAM Q
        ..S ^SYS(0,SP,INDEX,"NAME")=%JNAM
        ..V MSAV*400+(MSAV=0):DDU I $V(0,0)=0 S ^("NEXT")="EMPTY" G NEWSP
        ..V M*400-2:DDU I $V(0,0)'=0 S ^("NEXT")="FULL" G NEWSP
        ..F J1=MSAV:1:M-1 V J1*400+398:DDU Q:$V(0,0)=0
        ..S J0=J1*400+(J1=0),J1=J1*400+398
BINSRCH ..S JJ=J0+(J1-J0+1\2) V JJ:DDU I $V(0,0)=0 S J1=JJ G JNXT
        ..S J0=JJ
JNXT    ..G BINSRCH:J0+1<J1 S ^("NEXT")=JJ+($V(0,0)'=0) G NEWSP
NOTJ    ..I PTY="SDP" S MAPS=CT+1,MAP=MSAV,TYU=VOLS(VOL)\4 D SDVAL
NEWSP   ..S PTY=NTY,CT=0 Q:NTY=""  S MSAV=M,START=M*400+(M=0) Q
NOTMP   ..W " -- not a valid"
WRNUM   ..W " Map block: DSM BLK # ",M*400+399,":",DDU,!
        ..G SEE
        .W $J(MPS(VOL)*400,8)," blocks" I STR'<0 W $J(FREE,8)," available."
        .S TOTFRE=TOTFRE+FREE,PM=PM+M Q
        I STR<0 V VOLS(1)+DTBL::$V(VOLS(1)+DTBL)#16384+32768 G DONE
        W !,"Total in volume set:",$J(MPS*400,8)," blocks",$J(TOTFRE,8)," available.",!
        V STRTAB+4::SATMM
        V ST+356::MPS+16+511\512+$V(ST+356)
        F I=6:2:$V(ST+34)#256-2 V STRTAB+I::0
        I VOLS=1 V STRTAB+6::STMAP
        E  V STRTAB+6::VOLS+49152
        F I=1:1:VOLS S A=3*I+STRTAB+4+(I#2) V VOLS(I)+DTBL::$V(VOLS(I)+DTBL)#16384+49152 D
        .I I#2 V A::MPS(I),A+2::VOLS(I)
        .E  V A::MPS(I)#256*256+$V(A),A+2::MPS(I)\256+(VOLS(I)*256)
        S NAM=0 F I=1:1:3 S NAM=NAM*32+($A(STNAM,I)#32)
        V STRTAB::NAM*2
        I (STR>-1) F I=1:1:M9 S %GNAME=%GNAME(M9),%UCIN=%GNAME(M9,1),%PROT=%GNAME(M9,2),%KILL=%GNAME(M9,3) D %MAP^%GGP
        D LOAD^REPTAB
        I $V(ST+276) D KILL,UPDTAB^TRANTAB
DONE    S %A=0
KILL    ;
EXIT    K TY,MPS,UNS,TYPES,LABEL,STRTAB,CODE,VOLS,VOL,PM,FREE,TOTFRE,DTBL,PTY,NTY,V22,SATOF,SATMM,MSAV,J0,J1,%JNAM,SP,INDEX,JJ,SCT,SDP
        K I9,J9,K9,L9,M9,%S,%PROT,%GNAME,%KILL
        Q
READ    S $ZT="ERR" U 63:(::"ZT") V 0:DDU U 63:(::"C"),0 I STR'<0 S A=394,L=4
        E  S A=304,L=22
        S S="" F I=1:1:L S S=S_$C($V(LABEL+A+I-1,0)#256)
        S %A=0 Q
ERR     U 63:(::"C"),0 S %A=1 Q
MAPRD   S $ZT="MAPER" V M*400+399:DDU S %A=0 Q
MAPER   S %A=1 Q
CLNUP   I ($V(830,0)=12345)&($V(828,0)=54321) D
        .S J9=800,K9=$V(J9,0)
CLN1    .I K9'=65534 F I9=1:1 V 1022:0:$V(1022,0)+1 S L9=$V(K9*2,0) V K9*2:0:0 Q:L9=65534  S K9=L9
        .V J9:0:0
        .I J9=800 S J9=802,K9=$V(J9,0) G:K9 CLN1
CLN3    I $V(804,0) D
        .S M9=M9+1,%GNAME(M9)="",%GNAME(M9,1)=$V(804,0),%GNAME(M9,2)=255,%GNAME(M9,3)=1
        .F I9=806:2 Q:'($V(I9,0)#256)  S %GNAME(M9)=%GNAME(M9)_$C($V(I9,0)#256)
CLN4    I ($V(838,0)&($V(832,0)=12345)&(M=0)) D
        .S M9=M9+1,%GNAME(M9)="",%GNAME(M9,1)=$V(836,0),%GNAME(M9,2)=$V(834,0),%GNAME(M9,3)=0
        .F I9=838:2 Q:'($V(I9,0)#256)  S %GNAME(M9)=%GNAME(M9)_$C($V(I9,0)#256)
CLNEND  I 'M F I9=832:2:850 V I9:0:0
        F I9=800:2:830 V I9:0:0
        V -(M*400+399):DDU
        Q
        Q
SAMNAM  W !,"  (A JOURNAL space named  ' ",%JNAM," '  already exists.  "
        W "  renaming this second space to  ' ",DDU,":",START," ' )",! Q
RENAM   S %JNAM=DDU_":"_START
        F J0=0:1:11 S J1=$A($E(%JNAM,J0+1)) V:(J0#2) 990+J0-1:0:J1*256+$V(990,0) V:'(J0#2) 990+J0:0:J1
        Q
GETI    S INDEX=^SYS(0,SP,"INDEX"),^("INDEX")=INDEX+1 Q
MNTER   U 0 W !!,"Fatal error mounting ",DDU S %A=1 Q
SDVAL   S %VALTAB=$V($V(44)+138) G SDDON:'%VALTAB
        F %I=0:4:63 I $V(%I,%VALTAB)=0 G SPACE
        W !," ! (Current SDP validation table full -- contains 16 entries..."
        W !," No room for "
        W:MAPS>1 "maps ",MAP," thru ",MAP+MAPS-1,!," These maps"
        W:MAPS=1 "map ",MAP,!," This map" W " will not be accessible)",!
SPACE   V %I:%VALTAB:TYU*1024+MAPS,%I+2:%VALTAB:MAP
SDDON   K %VALTAB,%I Q
