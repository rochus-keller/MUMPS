%GD     ; GEF ; DSM UTILITIES ; GLOBAL DIRECTORY -
        S %LST=0
%GO     O 63::0 E  W !?5,"View Buffer busy" G END
        S $ZT="ERR"
        I '$D(%UCI)!'$D(%SYS) D ^%GUCI
        G:%LST %SKP W !,?20,"Global Directory  ",?42 D ^%D
        W !,?24,"of ",%UCI,",",%SYS,?42 D ^%T W !
%SKP    S:'$D(%PGC) %UCIN=$P($ZU(%UCI,%SYS),",") S %STB=$V(44),%UCNUM=%UCIN-1*20
        S %MM=$V($P($ZU(%UCI,%SYS),",",2)*($V(%STB+34)#256)+$V(%STB+12)+2)
        S %BLK=$V(%UCNUM+4,%MM)#256*65536+$V(%UCNUM+2,%MM),%CT=0
        S %S="S"_$P($ZU(%UCI,%SYS),",",2)
%VIEW   V %BLK:%S
        S %END=$V(1022,0),%NAM="",%PT=0
%NXT    G %PTR:%END'>%PT
%C      S %A=$V(%PT,0)#256,%PT=%PT+1,%NAM=%NAM_$C(%A\2) G %C:%A#2
        S %I=$I U 0 R X:0 U %I I $T G END
        W:'(%CT#8) ! W ?%CT#8*10,%NAM
        S %CT=%CT+1,%PT=%PT+8,%NAM="" G %NXT
%PTR    S %BLK=$V(1016,0)#256*65536+$V(1014,0) I %BLK G %VIEW
        D EXT I '%LST W !,?5,%CT," Global" W:%CT'=1 "s" W !
END     S $ZT="" C:'%LST 63 K %UCI,%SYS,%A,%CT,%DTO,%I,%NAM,%PT,%BLK,%END,%LST,%STB,%UCN,ANS,X,%TTAB,%HD,%X,%OFS,%SUCN K:'$D(%PGC) %
UCNUM,%UCIN,%MM,%S Q
ERR     I $ZE?1"<INRPT".E W !!,"Aborted..." G END
        E  W !,"Error = ",$ZE Q
%LST    S %LST=1 W ! G %GO
EXT     Q:'$V(%STB+276)  S %TTAB=$V(%STB+276)
        S %SUCN=$E(%S,2)*32+%UCIN,%HD=0,%OFS=$V(%SUCN,%TTAB)#256*4+252 Q:%OFS<256
        F %OFS=%OFS:14 Q:'$V(%OFS,%TTAB)  I $V(%OFS+9,%TTAB)<129 S %CT=%CT+1 D
        .I '%HD W !!,"Translated References:",!! S %HD=1
        .W:$X>70 ! W ?$X+19\20*20,"["
        .I $V(%OFS+12,%TTAB) S %I=10 D  W "," S %I=12 D  W "]"
        ..S %X=$V(%OFS+%I,%TTAB) W $C(%X\2048#32+64,%X\64#32+64,%X\2#32+64)
        .E  S %X=$V(%OFS+10,%TTAB)#256 W $ZU(%X#32,%X\32),"]"
        .F %I=0:1:7 S %C=$V(%OFS+%I,%TTAB)#256 Q:'%C  W:%C'=255 $C(%C) I %C=255 W "*" Q
        K %C Q
