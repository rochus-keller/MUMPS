UCILI   ;JHM;18-JUN-80;LIST ALL UCI'S ON SYSTEM
        D START^%STRTAB S ST=$V(44),STBL=$V(ST+12)
        F STR=0:1:7 I $D(STR(STR)),STR(STR)'="" D
        .W !!,"UCI's for Volume Set ",STR(STR)," (S",STR,")",!
        .S %UCTAB=$V($V(ST+34)#256*STR+2+STBL) F %OFF=0:20 S %=$V(%OFF,%UCTAB) Q:%=0  D:%'=65535 UCPRI
        K %UTAB,%OFF,%,%UCI,%I,STR,ST Q
UCPRI   S %UCI="",%=%\2 F %I=1:1:3 S %UCI=$C(%#32+64)_%UCI,%=%\32
        U 0 W !,"UCI # ",%OFF+20\20,?10,%UCI Q
