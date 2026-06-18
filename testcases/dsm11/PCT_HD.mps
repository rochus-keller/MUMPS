%HD     ;12-Dec-84 ;DSM11 ;UTILITIES ;CONVERT HEX TO DECIMAL ;
        I '$D(%HD) S %HD=0 Q
        S %H="" F %K=1:1:$L(%HD) D
        .S %N=$E(%HD,%K)
        .I "abcdef"[%N S %N=$C($A(%N)-32)
        .S %H=%H_%N
        S %HD=0
        F %K=1:1:$L(%H) S %D=$E(%H,%K) D EVAL Q:%HD="*"  S %HD=%HD*16+%D
        K %D,%H,%K,%N
        Q
EVAL    Q:%D?.N
        S %D=$F("ABCDEF",%D) I %D'>0 S %HD="*" Q
        S %D=8+%D
        Q
