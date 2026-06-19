%OD     ;  DSM UTILITIES ; OCTAL TO DECIMAL CONVERTER
        I '$D(%OD) W !,"This is a subroutine and is not intended for interactive use.",!,"For interactive conversion, use %DOC.",! Q        I %OD'?1N.N!($L(%OD)>27)!(%OD[8)!(%OD[9) S %OD="B" Q
        S %B=0 F %I=1:1:$L(%OD) S %B=%B*8+$E(%OD,%I)
        S %OD=%B K %I,%B Q
