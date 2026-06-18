BSCXMT  ;2-Sep-82 ;UTILITY ;BSC ;2780/3780 PE TRANSMITTER ;JHM
STRT    D CHKHLT G SHTDWN^BSCPEB:'$T S %RC=%RECMAX
        S %RVI=0,%R=^BSCDAT(%DEV,"SEND",%FN)
        S ^BSCDAT(%DEV)="TRANSMITTING "_%R U %DEV:(:%RDR)
        S %GQ=$P(%R," ",2,255),%CMOD=$P(%R," ",1)
        S %ZT=$ZT,$ZT="BADREF",%A=$D(@%GQ),$ZT=%ZT
        I '%A S %MSN=13,%Q="ERROR",%E="Undefined reference" D DQUE G NXTFIL
        S %MSN=15,%AP=%GQ D SNDMES^BSCPEB
        I $E(%GQ,$L(%GQ))=")" S %GQL=$E(%GQ,1,$L(%GQ)-1)_","
        E  S %GQL=%GQ_"("
        S %GO=%GQL,%GQL=%GQL_""""")" G NTPR:%CMOD="N"
TPR     I %CSET="A" S %MSN=12,%Q="ERROR",%E="Attempt to send transparent data in ASCII mode" D DQUE G NXTFIL
        U %DEV:("T":%RDR) D GETREC
T1      S %RC=%RECMAX W *2
        F I=$L(%LN):1:79 S %LN=%LN_$C(0)
        W %LN G ENDFIL:%RVI D GETREC G ENDFIL:%GQL=""
        W *%ETB G T1:$ZA=1 D GETZA G CHKERR:$ZA<0 I @%SRVI S %RVI=1
        G T1
NTPR    U %DEV:(%CSET:%RDR) D GETREC
N1      S %RC=%RECMAX W *2
N2      W %LN
        I $L(%LN)<80,'%EMUL W $C(25)
        G ENDFIL:%RVI D GETREC G ENDFIL:%GQL=""
        I '%EMUL*3+$L(%LN)+6<$ZB,%RC W *%RECTRM G N2
        W *%ETB G N1:$ZA=1 D GETZA G CHKERR:$ZA<0 I @%SRVI S %RVI=1
        G N1
ENDFIL  W *3 G NEWFIL:$ZA=1 D GETZA I @%SRVI S %RVI=1 G NEWFIL
        G CHKERR
NEWFIL  I %GQL'="" S ^BSCDAT(%DEV,"SEND",%FN)=%CMOD_" "_%GQL
        E  S %MSN=7,%Q="SENT",%E="" D DQUE
NXTFIL  I %RVI S ^BSCDAT(%DEV,"STATUS","RVI")=^BSCDAT(%DEV,"STATUS","RVI")+1 G IDLE
BEGIN   S %FN=$O(^BSCDAT(%DEV,"SEND","")) G IDLE:%FN="",STRT
CHKERR  I @%ECNTN G IDLE
        S %AP="" F %I=1:1:$P($T(ERRTAB)," ",2) I @$P($T(ERRTAB+%I)," ",2) S %AP=%AP_$E($T(ERRTAB+%I),4,8)_" "
        S %MSN=11,%AP=%GQ_" "_%AP D SNDMES^BSCPEB
        G DISCON^BSCPEB
IDLE    U %DEV W *%EOT G STRIDL^BSCPEB
GETREC  S %RC=%RC-1 G G1:%REC'=""
        S %GQL=$ZO(@%GQL) I %GQL=""!($E(%GQL,1,$L(%GO))'=%GO) S %GQL="" Q
        S %REC=@%GQL
G1      S %LN=$E(%REC,1,%RECSIZ),%REC=$E(%REC,%RECSIZ+1,255) Q
GETZA   U %DEV S HIZ=$ZA\65536,LOZ=$ZA#65536 Q
CHKHLT  ZA ^BSCDAT(%DEV):10 ZD ^BSCDAT(%DEV) Q
DQUE    S %AP=%GQ D SNDMES^BSCPEB
        S ^BSCDAT(%DEV,%Q,%FN)=%DAT1_" "_%TIM1_" "_%GQ_" "_%E
        S ^BSCDAT(%DEV,%Q)=^BSCDAT(%DEV,%Q)+1 K ^BSCDAT(%DEV,"SEND",%FN) Q
ERRTAB  8
        @%ENDSR
        @%ENCXR
        @%EENQX
        @%ENAKX
        @%ETIMO
        @%ENCTS
        @%ECNTN
        @%EABOR
BADREF  S %MSN=14,%Q="ERROR",%E=$ZE,$ZT=%ZT D DQUE G NXTFIL
