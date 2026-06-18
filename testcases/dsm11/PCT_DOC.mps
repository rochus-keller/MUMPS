%DOC    ; GEF ; DSM UTILITIES ; OCTAL - DECIMAL CONVERTER
        S $ZT="%ERR^%DOC"
%A      R !,"Enter number >   ",%X G %Q1:%X="?" I %X=""!(%X="^") K %X,%ZE Q
        I %X?1N.N S %DO=%X D %DO I $D(%DO) W "     #",%DO K %DO G %A
        I %X'?1"#"1N.N D %IV G %A
        S %OD=$E(%X,2,999) D %OD I '$D(%OD) D %IV G %A
        W "     ",%OD K %OD G %A
%DO     ;
        I %DO'?1N.N K %DO Q
        S %A="",%Y=%DO
        F %I=1:1 S %A=%Y#8_%A,%Y=%Y\8 Q:'%Y
        I %Y S %A=%Y_%A
        S %DO=%A
        K %A,%Y,%X,%I Q
%OD     ;
        I %OD["8"!(%OD["9") K %OD Q
        S %M=1,%S=""
        F %I=$L(%OD):-1:1 S %S=%S+(%M*$E(%OD,%I)),%M=%M*8
        S %OD=%S K %I,%M,%S Q
%Q1     W !!,?5,"Enter   ^ or <CR> To quit"
        W !,?8,"or   A decimal integer"
        W !,?8,"or   #  followed by an octal integer"
        W !,?8,"or   ?  for this message",! G %A
%IV     W !,?5,"Incorrect response - Enter '?' for more information" Q
%ERR    I $ZE?1"<MXNUM>".E W "  Too large" G %DOC
        W !,$ZE Q
