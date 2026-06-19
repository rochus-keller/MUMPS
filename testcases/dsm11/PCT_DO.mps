%DO     ; GEF ; DSM UTILITIES - DECIMAL TO OCTAL CONVERTER
        I '$D(%DO) W !,"This is a subroutine, and is not intended for interactive use.",!,"For interactive conversions, use %DOC." Q        I %DO'?1N.N!($L(%DO)>27) S %DO="B" Q
        S %B=%DO,%DO=""
AA      S %DO=%B#8_%DO,%B=%B\8 G:%B>7 AA S:%B %DO=%B_%DO K %B Q
