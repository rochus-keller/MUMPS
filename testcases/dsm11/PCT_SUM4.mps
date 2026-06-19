%SUM4   ;REPRINT SUMMARY : JEC ; 23-SEP-80 11:08 AM
        O 0 U 0 R !!,"Reprint which summary: ",A G END:A=""!(A?1"^".E),A2:A'?1"*".E
        S (I,J)=0 W !
A1      S I=$N(^UTILITY("SUM1",I)) I I<0 G %SUM4:J W *7,!!,?4,"No summaries on file" G END
        I $D(^UTILITY("SUM1",I,0,0)) W !,I,?10,^(0) S J=1
        G A1
A2      I A?1"?".E W !!,"Enter either a summary name or a '*' to get a list of current summaries on file" G %SUM4
        I '$D(^UTILITY("SUM1",A,0,0)) W *7,!,?4,"No such summary" G %SUM4
        W "   ",^(0)
A3      R !,"Summary or Symbol table format: <Summary> ",X G %SUM4:X?1"^".E I X?1"?".E W !!,"   Enter either Summary, Symbol or <CR> for the default for the format desired",! G A3
        S %SWT=1 I X'="","SYMBOL TABLE"[X S %SWT=0 W $E("SYMBOL TABLE",$L(X)+1,12)
        G A5:%SWT
A4      R !,"Overall symbol table only? <Yes> ",X G A3:X?1"^".E I X?1"?".E W !!,"   Enter either Yes, No or <CR> for the default",!
G A4
        S %SUM=0 I X]"",X'?1"Y".E S %SUM=1
A5      S %JB=A,IOO=$I,%DEF=$I D ^%IOS G END:'$D(%IOD) S %IO=%IOD G DET:IOO=%IO
USR     O 0 U 0 R !,"User name: ",ARF G A5:ARF?1"^".E I ARF?1"?".E W "  Enter a name to put on the report header" G USR
HDR     R !,"Do you want a single line (S), full block (F) or no header (N) on listing: <F> ",%HEADER,! I "S,F,N"'[%HEADER W *7,!?4,"  Please enter either an S, F, N or <CR> for the default",! G HDR
DET     I IOO=%IO W !!,"Please wait..."
        E  S STR=%JB_" SUMMARY FOR  "_ARF W !!,"Exit",!! C $I,%IO S %DV=%IO B 1
        I %SWT D ^%SUM2 G A6
        D ^%SUM3
A6      I IOO'=%IO W #### C %IO H
        G %SUM4
END     Q
Z       P %SUM4 ZS %SUM4
