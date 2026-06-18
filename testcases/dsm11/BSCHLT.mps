BSCHLT  ;20-Sep-82 ;UTILITY ;BSC ;HALTS THE BSCPE SPOOLER ;JH
START   W !!
Q1      S %QRY="Halt spooler for device" D GETDEV^BSCSTR G EXIT:%DEV="^"
        O %DEV::0 I $T W !,"Device ",%DEV," is not currently spooled",! C %DEV G Q1
        C %DEV
        W !,"Halting BSC PE spooler for device ",%DEV
        L ^BSCDAT(%DEV) O %DEV C %DEV W !,"Spooler has halted",!! L
        Q
EXIT    K %DEV Q
