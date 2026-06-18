BSCPEB  ; 30-Aug-82 ; UTILITY ; BSC ; 2780/3780 PE BACKGROUND JOB SPOOLER ; JHM
        S $ZT="TRAP^BSCPEB"
NOTRP   D ^BSCPER S %DEV="STARTING",%LOG="T",%TRN=1
STRT    ZA ^BSCDAT:1 I '$T S %MSN=1 D SNDMES D CHKHLT G SHTDWN:'$T,STRT
        S %DEV=^BSCDAT ZD ^BSCDAT Q:%DEV=""
        S %CSET=^BSCDAT(%DEV,"STARTUP","CSET"),%LMOD=^("LMOD"),%NMOD=^("NMOD"),%EMUL=^("EMUL"),%GIN=^("GIN"),%LOG=^("LOG"),%TRN=^("T
RN"),%RECSIZ=^("REC"),%SIGN=^("SIGNON")
        I $E(%GIN,$L(%GIN))=")" S %GSUB=$E(%GIN,1,$L(%GIN)-1)_","
        E  S %GSUB=%GIN_"("
        I '$D(@%GIN)#2 S @%GIN=0
        I %EMUL=2 S %BUFSIZ=512,%RECMAX=256,%RECTRM=30,%RDR=240 S:%CSET="A" %RDR=48
        E  S %BUFSIZ=400,%RECMAX=7,%RDR=246,%RECTRM=31 S:%CSET="A" %RDR=54
        I %CSET="A" S %EOT=4,%ETB=23
        E  S %EOT=55,%ETB=38
OPDEV   S %P3=^BSCDAT(%DEV,"STARTUP","CUPOL"),%P4=^("CUSEL")
        O %DEV:(%EMUL_%CSET_%NMOD::%P3:%P4:%BUFSIZ):10
        I '$T S %MSN=3 D SNDMES,CHKHLT G SHTDWN:'$T,OPDEV
        S %EMUL=%EMUL-1,%MSN=4 D SNDMES,INIDAT,QSIGN
STRIDL  S ^BSCDAT(%DEV)="IDLE"
IDLE    D CHKHLT G SHTDWN:'$T U %DEV:"C" R %REC:1
        I $T G ^BSCRCV:$ZA'<0,DISCON:%LMOD="L" H 10 G IDLE
CHKFIL  S %FN=$O(^BSCDAT(%DEV,"SEND",0)) G BEGIN^BSCXMT:%FN'=""
        I %LMOD="L" H 10 G IDLE
        U %DEV R %REC:30 G:'$T DISCON G:$ZA'<0 ^BSCXMT
DISCON  D GETZA,LOGERR I %LMOD="S" W *16 U %DEV:"D" D QSIGN
        I %LMOD="L",@%ENDSR S %MSN=8 D SNDMES
        H 10 G IDLE
GETZA   U %DEV S HIZ=$ZA\65536,LOZ=$ZA#65536 Q
CHKHLT  ZA ^BSCDAT(%DEV):10 ZD ^BSCDAT(%DEV) Q
QSIGN   Q:%SIGN=""  S ^BSCDAT(%DEV,"SEND",0)="N "_%SIGN Q
INIDAT  F %I="SEND","RCVD","ERROR","SENT" I '$D(^BSCDAT(%DEV,%I)) S ^(%I)=0
        S ^("STATUS","RVI")=0
        F %I=1:1:$P($T(LOGTAB)," ",2) S ^($E($T(LOGTAB+%I),4,8))=0
        Q
LOGERR  F %I=1:1:$P($T(LOGTAB)," ",2) I @$P($T(LOGTAB+%I)," ",2) S %E=$E($T(LOGTAB+%I),4,8),^BSCDAT(%DEV,"STATUS",%E)=^BSCDAT(%DEV,"
STATUS",%E)+1
        Q
TRAP    S ^BSCDAT(%DEV)="Crashed "_$ZE S %MSN=2,%AP=$ZE D SNDMES Q
SNDMES  D INT^%D,INT^%T S %I="BSCPE - "_%DAT1_" "_%TIM_" Device: "_%DEV_" "_$T(MESTAB+%MSN) S:$D(%AP) %I=%I_" "_%AP K %AP
        Q:%LOG="S"  I %LOG="T" ZU %TRN W !,%I,*7 Q
        S %E=$D(^BSCDAT(%DEV,"MESSAGE",+$H))#2 S:%E %E=^(+$H)+1 S ^BSCDAT(%DEV,"MESSAGE",+$H)=%E,^(+$H,%E)=%I Q
MESTAB  ;
        Unable to ZAllocate ^BSCDAT                 -
        Unrecoverable error encountered             -
        Unable to OPEN                              -
        Spooler started                             -
        Spooler disabled                            -
        Data received                               -
        Data transmitted                            -
        Data Set not ready                          -
        Carrier not present                         -
        Transmission aborted while receiving data   -
        Transmission aborted while sending data     -
        Transparent data not sent in ASCII mode     -
        Queued global is not defined                -
        Queued global reference syntax is illegal   -
        Data transmission started                   -
        Data reception started                      -
LOGTAB  6
        @%ENDSR
        @%ENCXR
        @%EENQX
        @%ENAKX
        @%ETIMO
        @%ENCTS
SHTDWN  S %MSN=5,^BSCDAT(%DEV)="DISABLED" D SNDMES
EXIT    Q
