BSCSTA  ;30-Sep-82 ;UTILITY ;BSC ;DISPLAYS PE SPOOLER STATUS ;JHM
STRT    W !!
Q1      S %QRY="Status for spooler device number" D GETDEV^BSCSTR G EXIT:%DEV="^"
        I $D(^BSCDAT(%DEV))'#2 W !,"The spooler for this device has never been run" G Q1
Q2      S %QTY=2,%DEF=0 D ^%IOS G Q1:'$D(%IOD),STA:"TRM,LP,SC"[%DTY
        W !,"Invalid output device type" G Q2
STA     I %IOD'=$I W !,"Printing report at: " D ^%T
        S %FF=1 U %IOD
        W:%FF # W !!,"BSC protocol emulator status at: " D ^%D W " " D ^%T
        W !,"Device:",?20,%DEV
        W !,"State:",?20,^BSCDAT(%DEV)
        W !!,"Startup configuration",!
        W !,"Logging device:",?25,$S(^BSCDAT(%DEV,"STARTUP","LOG")="T":"Terminal "_^("TRN"),^("LOG")="L":"Log file",1:"Logging suppr
essed")
        W !,"Character set:",?25,$S(^("CSET")="E":"EBCDIC",^("CSET")="T":"Transparent",1:"ASCII")
        W !,"Emulator mode:",?25,$S(^("EMUL")=2:3780,1:2780)
        W !,"Line configuration:",?25,$S(^("LMOD")="L":"Leased",1:"Switched")
        W !,"Network configuration:",?25,$S(^("NMOD")="P":"Point-to-point",1:"Multipoint")
        I ^("NMOD")="M" W !,"Unit Poll-Select Codes:",?25,^("CUPOL"),"/",^("CUSEL")
        W !,"Maximum record size:",?25,^("REC")
        W !,"Global receiving data:",?25,^("GIN")
        I ^("SIGNON")'="" W !,"Signon file name:",?25,^("SIGNON")
        S %Q="ERROR",%T="Files dequeued due to errors" D SHOQ
        S %Q="SENT",%T="Files successfully sent" D SHOQ
        S %Q="RCVD",%T="Files successfully received" D SHOQ
        S %Q="SEND",%T="Files queued to be sent" D SHOQ
        W !!,"Error and event counts:",!
        F %I=1:1:$P($T(ERRLOG)," ",2) W !,$P($T(ERRLOG+%I),"^",3),":",?30,^BSCDAT(%DEV,"STATUS",$P($T(ERRLOG+%I),"^",2))
        S (%D,%E)="" I $D(^BSCDAT(%DEV,"MESSAGE"))'>1 G DONE
        W !!,"Log file entries:",!
STA2    S %D=$O(^BSCDAT(%DEV,"MESSAGE",%D)) G DONE:%D=""
        F %I=0:0 S %E=$O(^BSCDAT(%DEV,"MESSAGE",%D,%E)) G STA2:%E="" W !,^(%E)
DONE    W !! W:%FF #
EXIT    I $D(%IOD) U 0 C:%IOD'=$I %IOD
        K %DEV,%Q,%T,%I,%IOD,%E,%D Q
SHOQ    I $O(^BSCDAT(%DEV,%Q,""))="" Q
        W !!,%T,":",! S %FN="" F %I=0:0 S %FN=$O(^BSCDAT(%DEV,%Q,%FN)) Q:%FN=""  W !,^(%FN)
        Q
ERRLOG  7
        ^EENQX^ENQ thresholds exceeded
        ^ENAKX^NAK thresholds exceeded
        ^ENCTS^Clear To Send errors
        ^ENDSR^Data Set Ready errors
        ^ENCXR^Carrier not received
        ^ETIMO^IO timeout errors
        ^RVI^RVI's received
