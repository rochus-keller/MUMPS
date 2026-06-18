%PS     ;15-Dec-80 ;UTILITY ;PROGRAM MAINTENANCE ;SAVES PROGRAM FILES ;JHM
        W !!,"PROGRAM SAVE",! S %QTY=2 K %DEF D ^%IOS I '$D(%IOD) D %DONE Q
        I "TRM,LP,SDP,MT,SC"'[%DTY W !,?5,"INVALID DEVICE SELECTION" D %DONE G %PS
        I %DTY="SDP" S %MTM="D"
        S FFM=2
        G:"MT"'[%DTY %HEAD
        U %IOD S ZA=$ZA I @(%MTON_"=0") U 0 W !,"DRIVE NOT READY" D %DONE G %PS
        I @%MTWLK U 0 W !,"TAPE IS WRITE PROTECTED" D %DONE G %PS
        I @(%MTBOT_"=0") U 0 D %REW^%IOS I '$D(%REW) D %DONE G %PS
%HEAD   U 0 R !,"HEADER COMMENT... ",%HEAD I %HEAD="^" D %DONE G %PS
        I %HEAD="?" W !,?5,"ENTER FREE TEXT TO BE USED AS HEADING",! G %HEAD
%RSEL   D ^%PSEL G:'%GO %PS
        S %NAM="",%CT=0 I $ZS(^UTILITY($J,%NAM))="" D %DONE G %PS
        D INT^%D,INT^%T I "MT,SDP,TRM"'[%DTY U %IOD:130
        E  U %IOD
        I "MT,SDP"'[%DTY D @FFM W !,"PROGRAM LISTING "
        E  I %MTM["V" W %DAT_"     "_%TIM,%HEAD
        E  W %DAT,"     ",%TIM,!,%HEAD,!
        I "MT,SDP"[%DTY S %CT=0,%NAM=-1 U 0 W ! G %G2
%G1     S %NAM=$ZS(^(%NAM)) I %NAM="" S %NAM=-1,%CT=0 U 0 W ! G %G2
        U %IOD W:'(%CT#4) ! W ?(%CT#4*20),%NAM S %CT=%CT+1 G %G1
%G2     S %NAM=$N(^UTILITY($J,%NAM)) G %TERM:%NAM=-1
        S T=$P($P(%NAM,".",2),";",1),N=$P(%NAM,".",1),V=$P(%NAM,";",2)
        U 0 I $I'=%IOD W:'(%CT#4) ! W ?(%CT#4*20),%NAM S %CT=%CT+1
        U %IOD I "MT,SDP"'[%DTY D NP S I=$P(^PRG(T,N,V,0),"^",1),%CT=%CT+1 G %G3
        I %MTM["V" W T,N
        E  W T,!,N,!
        S I=-1 F %I=0:0 S I=$N(^PRG(T,N,V,I)) Q:I=-1  W I W:%MTM["V" ^(I) W:%MTM'["V" !,^(I),!
        I %MTM["V" W "*","*"
        E  W "*",!,"*",!
        G %G2
%G3     S I=$P(^PRG(T,N,V,I),"^",1) I 'I G %G2
        D NP:$Y>63 W $P(^PRG(T,N,V,I),"^",3,9999),! G %G3
%TERM   U %IOD I "MT,SDP"'[%DTY W ! D @FFM D %DONE G END
        I %MTM["V" W "**","**"
        E  W "**",!,"**",!
        D %DONE G END
%DONE   U 0 K %HEAD,%CT,%DTY,%NAM,%DAT,%TIM,I,%GO,FFM,T,N,V
        I $D(%IOD) U 0 C:(%IOD'=$I) %IOD K %IOD
        Q
1       F %I=1:1 Q:'($Y#66)  W !
        U %IOD:(::::::0) ;;CLRY
        Q
2       W # Q
NP      D @FFM W ^PRG(T,N,V,2),!! Q
END     K %UTILITY,%D,%G,%IOD,%ZIOD,%DTY,%B,%N,%HEAD,%NG Q
        -
Z       X "ZP %GS ZS %GS"
