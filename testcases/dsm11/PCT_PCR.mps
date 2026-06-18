%PCR    ;15-Dec-81 ;UTILITY ;EDITOR ;EDITOR ERROR MESSAGES ;JHM
DUPTAG  U 0 W !,"*ERROR* - Duplicate tag : ",TAG S BD=1 Q
BADTAG  U 0 W !,"*ERROR* - Control characters in tag : ",TAG S BD=1 Q
NODEM   U 0 W !,"*Warning* - missing end of symbol delimiter in line : ",!,LINE S BD=1 Q
RECSYM  U 0 W !,"*ERROR* - Can't parse recursive symbol in line : ",!,LINE S BD=1 Q
BADSYM  U 0 W !,"*ERROR* - Bad symbol name : /*",SYM,"*/" S BD=1 Q
NOSYM   U 0 W !,"*ERROR* - Undefined symbol : ",SYM S BD=1 Q
BADMAC  U 0 W !,"*ERROR* - Bad macro name : ",MACNM S BD=1 Q
DUPMAC  U 0 W !,"*ERROR* - Recursive macro call : ",MACNM S BD=1 Q
MACERR  U 0 W !,"*ERROR* - Unable to open macro file : ",MACNM
        W !,"$ZE = ",ZE S BD=1 Q
BDSRC   U 0 W !,"*ERROR* - Unable to access source file : ",%SRC
        W !,"$ZE = ",ZE S BD=1 Q
COMPERR U 0 W !,"*ERROR* - Unable to compile : ",PNAM
        W !,"$ZE = ",ZE S BD=1 Q
NOVAR   U 0 W !,"*Warning* - Missing macro calling argument : ",A," in call to : ",MACNM Q
EXTVAR  U 0 W !,"*Warning* - Extra macro calling arguments : ",ARG," in call to : ",MACNM Q
NODEC   U 0 W !,"*ERROR* - Symbol not declared : ",SYM," in macro : ",%SRC Q
BDVAR   U 0 W !,"*Warning* - Bad macro argument : ",A," in macro : ",MACNM Q
NOMAC   U 0 W !,"*ERROR* - Can't find macro : ",MACNM Q
BDCMD   U 0 W !,"*ERROR* - Bad directive command : ",LINE Q
BDCMR   U 0 W !,"*ERROR* - Bad .IF argument : ",LINE Q
CMERR   U 0 W !,"*Warning* - Missing directive complement" Q
STERR   U 0 W !,"*ERROR* - Unable to save routine",!,"$ZE = ",ZE Q
