TAPCOPA ;DSM11 Utilities; Copyright 1980 DEC
        Q
ONECOP  ;
        S (%FAIL,TMK,EOTI,EOTO)=0
NXBLK   U UF W *6 G:$ZA>127!($ZA<64) INCHK S ZB=$ZB,TMK=0
NXO     U UT:(ZB:0) W *4 G:$ZA>127!($ZA<64) OUCHK G:EOTI=0 NXBLK
NXO2    U 0 I EOTI=1 W !,"(Past End-Of-Tape marker on Input Tape -- not an "
        I  W "error)",!
        I EOTI=4 S QUES="EIQ" X ^%Q("ASKY") G TERM:ANS="N"!%A,NXBLK
        G NXBLK:EOTO=1 G NXBLK:EOTI<4&(EOTO<2)
        S QUES="TRY1Q" X ^%Q("ASKY") G TERM:ANS="N"!%A,NXBLK
COPDON  U 0 W !,"** Copy Complete **",!
RETURN  G RET^TAPECOPY
INCHK   S TAPMRK=$ZA\16384#2,EOT=$ZA\1024#2,ZA=$ZA-(TAPMRK*16384)-(EOT*1024)
        G:ZA>127!(ZA<64) INER
        I TAPMRK U UT W *3 S TMK=TMK+1 G NXBLK:TMK=1,COPDON
        S EOTI=EOTI+1 G NXO
OUCHK   S EOT=$ZA\1024#2,ZA=$ZA-(EOT*1024)
        G:ZA>127!(ZA<64) OUER S EOTO=EOTO+1 G:EOTO>1 NXO2
        U 0 S QUES="EOQ" X ^%Q("ASKY") G TERM:ANS="N"!%A,NXO2
INER    S ZA=$ZA U 0 W !!,"** ERROR READING INPUT TAPE:" G ERR
OUER    S ZA=$ZA U 0 W !!,"** ERROR WRITING OUTPUT TAPE:"
ERR     W "   $ZA= ",ZA," (DECIMAL)"
TERM    W !," -- STOPPING.",! S %FAIL=1 G RETURN
EOQ     W !,"** PAST END-OF-TAPE MARKER ON  * OUTPUT * TAPE"
        W "  (INPUT TAPE NOT TERMINATED YET)",!
TRY1Q   W "   COPY NEXT BLOCK" Q
TRY1QH  ;
EIQH    ;
EOQH    W !,"If you answer 'N', the copy will be terminated.  However, the "
        W "tapes will",!
        W "remain positioned exactly where they are now, so you may re-open "
        W "them",!
        W "and (for example) write 2 tapemarks on the Output tape, or examine "
        W "blocks",!,"of the Input tape.",!!
        W "If you answer 'Y' (the default answer), exactly one more physical "
        W "block will",!
        W "be copied from the Input tape to the Output tape, then you will be "
        W "given",!
        W "another chance to decide whether to copy an additional block.  "
        W "(However, if",!
        W "2 consecutive Tapemarks are encountered from the Input tape, the "
        W "Copy will",!
        W "end successfully with the message ""Copy Complete"".)",!!
        Q
EIQ     W !,"** ",EOTI," BLOCKS PAST END-OF-TAPE MARKER ON  * INPUT * TAPE",!
        W "   -- INPUT TAPE NOT TERMINATED YET.",!
        G TRY1Q
