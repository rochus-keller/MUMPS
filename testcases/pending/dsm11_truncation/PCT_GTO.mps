%GTO    ;1-May-86 ;DSM ;V 3.2 ;Global output ;kfd
        W !!,"This routine saves globals to be restored by %GTI",! S %RET="GLOB^%GTO",%INT=""
DEV     S %QTY=2 K %DEF D ^%IOS I '$D(%IOD) G DONE
        S $ZT="ERR^%GTO"
        I "MT,TRM,SDP,LP,SC"'[%DTY!(%DTY="") W !,"Improper device selection" G DONE
        G HEAD:%DTY'["MT"
        U %IOD I @(%MTON_"=0") S XXX=$ZA U 0 W !,"Drive not ready" G DEV
        I @%MTWLK U 0 W !,"Tape is write protected" G DEV
        I @(%MTBOT_"=0") U 0 D %REW^%IOS I '$D(%REW) G DONE
%SET    U 0 S %CHK=0 I %DTY="MT" R !,"Do you want to check for control characters ? < NO > ",%CHK I %CHK="?" D CHKHLP^%G G %SET
        G DONE:%CHK="^" S %CHK=%CHK?1"Y".E
HEAD    U 0 R !,"Header comment... ",%HEAD I %HEAD="^" G DONE
        I %HEAD="?" W !,?5,"Enter any text to be used as a heading" G HEAD
HEAD1   K ^UTILITY($J) S %DIR=0,^UTILITY($J,"%")=0
GLOB    D GTO^%G1 I %="" G GO:^UTILITY($J,"%"),DONE
        I %="^" S %1X=^UTILITY($J,"%") G HEAD:'%1X S ^("%")=%1X-1 K ^("%",%1X) D DIS G GLOB
        S %1X=^UTILITY($J,"%")+1,^("%")=%1X,^("%",%1X)=%
        F %1I="C","D","M","P" S ^UTILITY($J,"%",%1X,%1I)=%(%1I)
        F %1I=0:1:%("C") F %1J=1:1 Q:'$D(%(%1I,%1J))  S ^UTILITY($J,"%",%1X,%1I,%1J)=%(%1I,%1J),^(%1J,"S")=%(%1I,%1J,"S") S:$D(%(%1I
,%1J,"C")) ^("C")=%(%1I,%1J,"C")
        G GLOB
        -
GO      ;D DIS:'%INT,INT^%D,INT^%T U %IOD S %1DTM=%DAT1_"     "_%TIM,%1EX="W $S(%G[""["":""^""_$E(%G,$F(%G,""]""),$L(%G)),1:%G),!,%D
,!"
GO      D DIS:'%INT,INT^%D,INT^%T U %IOD S %1DTM=%DAT1_"     "_%TIM,%1EX="W $S($E(%G,2)=""["":""^""_$E(%G,$F(%G,""]""),$L(%G)),1:%G)
,!,%D,!"
        S %1LF=1
        ;I %DTY="MT" S:%MTM["V" %1LF=0,%1EX="W $S(%G[""["":""^""_$E(%G,$F(%G,""]""),$L(%G)),1:%G),%D" S %1EX="S $ZT=""MT^%GTO"" "_%1
EX_" G:($ZA\1024#2) MT^%GTO"
        I %DTY="MT" S:%MTM["V" %1LF=0,%1EX="W $S($E(%G,2)=""["":""^""_$E(%G,$F(%G,""]""),$L(%G)),1:%G),%D" S %1EX="S $ZT=""MT^%GTO""
 "_%1EX_" G:($ZA\1024#2) MT^%GTO"
        I %DTY="SDP" S %1EX=%1EX_" G:$ZA<0 SDP^%GTO"
        S %1EX="I %DF#10 U %IOD "_%1EX_" U 0 R *%1X:0 I %1X>0 W !,""Currently on node: "",%G"
        U %IOD I %DTY="MT"!(%DTY="SDP") W %1DTM W:%1LF ! W %HEAD W:%1LF !
        E  W #,!,"Global listing ",%1DTM,!,%HEAD,!!
        I '%INT F %1GLS=1:1:^UTILITY($J,"%") D GLS
        I %INT F %1GLS=1:1:%INT S %=%INT(%1GLS) D INT^%G1 G INTER:%="" D GLS1
        U %IOD W "**END**" W:%1LF ! W "**END**" W:%1LF ! I %DTY="MT" W *3,*3 C %IOD O %IOD:%MTM_"T" U %IOD W *1
        S ZA=$ZA,ZB=$ZB U 0 W:%IOD'=$I&'%INT !,"Global transfer finished" I %IOD>58,%IOD<63 W " with block ",ZA," byte ",ZB
        I %IOD'=$I,'%INT W " at " D ^%T W !
        D KQ^%G G DONE
        -
GLS     U %IOD K % S %=^UTILITY($J,"%",%1GLS),ZA=$ZA,ZB=$ZB U 0 I %IOD'=$I W !,"Output started for ^"_% W:%IOD>58&(%IOD<63) " starti
ng with block ",ZA," byte ",ZB W " at " D ^%T
        F %1I="C","D","M","P" S %(%1I)=^UTILITY($J,"%",%1GLS,%1I)
        F %1I=0:1:%("C") F %1J=1:1 Q:'$D(^UTILITY($J,"%",%1GLS,%1I,%1J))  S %(%1I,%1J)=^(%1J),%(%1I,%1J,"S")=^(%1J,"S") S:$D(^("C"))
 %(%1I,%1J,"C")=^("C")
GLS1    S %("X")=%1EX,%GIOD=0 U 0 G GO^%G
        -
ERR     U 0 W !,$ZE
ERR1    U 0 Q:'$D(%IOD)  Q:%IOD=$I  C %IOD Q
        -
SDP     U %IOD S %1X=$ZA U 0 W !,"SDP ERROR: $ZA=",%1X S $ZT="ERR1" *
        -
MT      I $ZE["MTERR" U 0 W !,"MAGTAPE ERROR:",!! U %IOD D ^%MTCHK ZQ
        U %IOD I ($ZA\1024#2=0) U 0 ZQ
        U 0 W !!,"**  End of tape detected **",!!
        W "After current tape rewinds, mount next tape."
        U %IOD W "**END**" W:%1LF ! W "**EOT**" W:%1LF ! W *3,*3,*5
        U 0 R !,"Type <CR> to continue: ",%1X
        U %IOD W %1DTM W:%1LF ! W %HEAD W:%1LF ! S ZA=$ZA Q
        -
DIS     U 0 I ^UTILITY($J,"%")=0 W !,"NO GLOBALS SELECTED" Q
        W !,"GLOBAL SELECTED:" F %1I=1:1:^("%") W !,"^",^UTILITY($J,"%",%1I)
        Q
        -
DONE    U 0 I $D(%IOD),%IOD'=$I C %IOD
        K %,%DIR,%GIOD,%DAT,%DAT1,%TIM,%TIM1,I,%1J,%1X,ZA,%1DTM,%HEAD,%1EX,%1GLS,%1LF
        I %INT="" K %IOD,%DTY,%MTM
        K %INT Q
        -
INTER   U 0 W !,"SORRY, ",%INT," IS NOT A LEGAL GLOBAL REFERENCE" G DONE
        -
INT     S $ZT="ERR^%GTO" G GO
