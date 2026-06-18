%BN     ;FDN;3-JUN-80;CALCULATE ACTUAL DISK BLOCK FROM MUMPS BLOCK #
        S %DTYPE=%BN\2097152,%DUNIT=%BN\262144#8,%DBLOCK=%BN#262144
        W !,"Disk type = ",%DTYPE
        W !,"Unit no. = ",%DUNIT
        W !,"Block # = ",%DBLOCK
        W !,"Logical block no. = ",%DBLOCK*2
        Q
Z       P %BN ZS %BN Q
