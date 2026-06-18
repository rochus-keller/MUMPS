%IOS1   ;%IOS AUX.
%MODQ   R !,"Magtape Mode ? <D>  ",%DEF I %DEF="" S %DEF="D"
        S %MOD=%DEF Q:%MOD="^"  G %MODH:%MOD="?"
        F %X="AE",345,"FVS","LDU","T","C" F %DT=1:1:$L(%DEF) I %X[$E(%DEF,%DT) S %DEF=$E(%DEF,1,%DT-1)_"&"_$E(%DEF,%DT+1,99) Q
        I %DEF'?."&" D %IV G %MODQ
        D:%MOD["F" %RECL G:%DEF="^" %MODQ
        S %MTM=%MOD
%BLKQ   R !,"Block size ? <1024> ",%DEF Q:%DEF=""  G:%DEF="^" %MODQ G:%DEF="?" %BLKH
        G:(%DEF<20)!(%DEF>8192)!(%DEF#2=1) %BLKH S %BLK=%DEF Q
%BLKH   W !!!?3,"Enter the block size as the number of bytes to be contained in each block"
        W !?5,"Block size must be in the range 20-8192"
        W !?5,"Block size must be an even number of bytes",!! G %BLKQ
%MODH   W !!!?3,"Enter string of optional characters. Valid options are:",!!
        W !?5," A - Read/Write ASCII characters (default)"
        W !?5," C - Read/Write DOS labeling, asynchronous IO"
        W !?5," E - Read/Write EBCDIC characters"
        W !?5," D - DOS label (default)"
        W !?5," U - Unlabeled"
        W !?5," L - ANSI Standard Label if ASCII, IBM Standard Label if EBCDIC"
        W !?5," S - Stream data format (default)"
        W !?5," F - Fixed length records"
        W !?5," V - Variable length records"
        W !?5," T - User detection of Tapemarks (No MTERR)"
        W !?5," 3 - 800 BPI density"
        W !?5," 4 - 1600 BPI density (default)"
        W !?5," 5 - 6250 BPI density",!!
        W !?15,"Example:  Magtape mode <D> ? AVL",!!
        G %MODQ
%IV     W !,?5,"Incorrect response - Enter '?' for more information." Q
%Q1     W !!,?5," Enter the device number or mnemonic:",!
        W !,?16,"Any valid device number ( 0<= N <=255 ) except 63"
        W !,?16,"0     For the device you are now using"
        W !,?14,"47-50  (MT0-3)     For magnetic tape"
        W !,?14,"59-62  (SDP0-3)    For Sequential Disk"
        W !,?15,"<CR>   For default (e.g., <#> if any), or exit"
        W !,?16,"^     To terminate without selection",! Q
%RECL   S %DEF=80
        W !,"Record length - 1<=bytes <=255 - <",%DEF R ">: ",%DEF Q:%DEF="^"
        S:%DEF="" %DEF=80
        I %DEF<1!(%DEF>255) W !,"Incorrect response!",*7,! G %RECL
        S %RL=%DEF Q
