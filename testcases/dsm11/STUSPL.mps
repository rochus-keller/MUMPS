STUSPL  ;SET UP SPOOL DDB, START SPOOLING IF REQUESTED
        W "This routine may be called by start-up and ^SPL only." Q
SETDDB  D CHECK I %FAIL Q
        S DEVTAB=$V(ST+8) V DEVTAB+2::$V(DEVTAB+2)\256*256+255
        I '$D(^SYS(0,"SPOOL SPACE",1,"START")) Q
        S DIR=^("START"),DDU=^("DISK")
        S BAS=DIR-(DIR#400)
        D TYPES^DPBEGIN S TU=$F(TYPES,$E(DDU,1,2))\3-1*8+$E(DDU,3)*4
        S DDB=$V(ST+10)+$V(ST+68)
        V DDB+14::BAS#65536,DDB+16::TU*256+(BAS\65536)
        I $V(DDB+10)=0 D
        .C 63 O 63:(2:2:1)
        .S BDB=$V(ST+308)
        .V ST+312::1,BDB:$V(ST+508):257 C 63
        .S BDB=BDB+4
        .V BDB:$V(ST+506):0
        .V DDB+10::BDB,DDB+12::BDB/4-1*16+$V(ST+398)
        C 63 O 63:2
        W !,"Now integrity-checking the SPOOL structure..."
        S ER=0 U 63:(1:1),0 V DIR:DDU F FILE=1:1:255 D
        .U 63:(1:1),0 S BL=$V(FILE*4+2,0)#256*65536+$V(FILE*4,0) I BL=0 Q
        .U 63:(2:1),0 V BL+BAS:DDU
        .S END=$V(10,0)#256*65536+$V(8,0)
        .I END'=0 V END+BAS:DDU S NEXT=$V(2,0)#256*65536+$V(0,0) I NEXT=0 Q
        .S ER=ER+1,NXT=BL
        .U 0 W !,"File number ",FILE," is improperly terminated, now correcting problem..."
        .F I=1:1 V NXT+BAS:DDU S PRV=NXT,NXT=$V(2,0)#256*65536+$V(0,0),SEQ=$V(3,0)*65536+$V(4,0) I (NXT=0)!(SEQ'=I) Q
        .V PRV+BAS:DDU V 0:0:0,2:0:$V(3,0)*256 V -(PRV+BAS):DDU
        .V BL+BAS:DDU V 8:0:PRV#65536,12:0:PRV#65536,10:0:PRV\65536*257
        .V -(BL+BAS):DDU
        I ER=0 W !,"No errors found in SPOOL file.",!
        U 63:(1:1),0 V 0:$V(DDB+12):0:0:1024
        S BDB=$V(DDB+10)
        V BDB:$V(ST+504):$V(DDB+14)+(DIR=1),BDB+2:$V(ST+504):$V(DDB+16)
        V BDB:$V(ST+510):$V(DDB+14)+(DIR=1),BDB+2:$V(ST+510):$V(DDB+16)
        V BDB+2:$V(ST+508):$V($V(ST+308)+2,$V(ST+508))
        C 63
        V DEVTAB+2::$V(DEVTAB+2)-255 S %STSPL=1
        Q
CHECK   S %FAIL=0,%STSPL=0,ST=$V(44),OFT=$V(ST+136) I 'OFT W !,"Spooling not in system." Q
        S OFTNUM=$V(0,OFT)#256,OFTSIZ=$V(1,OFT)
        F I=1:1:OFTNUM I $V(I-1*OFTSIZ+2,OFT) W !,"Spool file #",$V(I-1*OFTSIZ+2,OFT)#256," is in use by job #",$V(I-1*OFTSIZ+4,OFT)
#256/2 S %FAIL=1
        Q
