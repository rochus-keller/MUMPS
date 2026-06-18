%PCOPY  ;15-Dec-80 ;UTILITY ;PROGRAM MAINTENANCE ;COPIES PROGRAM FILES ;JHM
        W !!,"PROGRAM COPY",!
UCI     W !,"Copy *TO* UCI ? <",$P($ZU(0),","),"> " R UCI G:UCI="^" END
        I UCI="?" W !,"Enter the UCI name to copy the programs",! G UCI
        I UCI="" S UCI=$P($ZU(0),",") W UCI
        I UCI'?3U D IV G UCI
SYS     W !,"Copy *TO* Volume Set ? <",$P($ZU(0),",",2),"> " R VOL G:VOL="^" UCI
        I VOL="?" W !,"Enter the Volume Set name to copy the programs" G SYS
        I VOL="" S VOL=$P($ZU(0),",",2) W VOL
        I VOL'?3U D IV G SYS
        S $ZT="PRGTST" S A=$D(^[UCI,VOL]PRG) S $ZT=""
        I 'A W !,"The program global is undefined in [",UCI,",",VOL,"]",! G UCI
%RSEL   D ^%PSEL G:'%GO END
        S %NAM="",%CT=0 I $ZS(^UTILITY($J,%NAM))="" G END
%ASK    R !,"Copy all (A) or selected (S) ? <A> ",%X,! G:%X="^" END
        I %X="?" W !,?5,"Enter A or S" G %ASK
        S %ALL=0 I %X=""!(%X="A") S %ALL=1
        E  I %X'="S" D IV G %ASK
%G2     S %NAM=$N(^UTILITY($J,%NAM)) G END:%NAM=-1
        S OLDT=$P($P(%NAM,".",2),";",1),OLDN=$P(%NAM,".",1),OLDV=$P(%NAM,";",2)
        I $D(^[UCI,VOL]PRG(OLDT,OLDN))#2 S NEWV=^(OLDN)+1
        E  S NEWV=OLDV
        I %ALL S NEWN=OLDN,NEWT=OLDT G %SAV
%RES    W !,"Copy as ? <",OLDN,".",OLDT,";",NEWV R "> ",%X,! G:%X="^" END
        I %X="-" W "  skipped" G %G2
        I %X="?" W !,"Enter a replacement name or <RETURN> to use the default",! G RES
        I %X="" G %SAV
        I %X'?1NUP.NUP!($P(%X,".",1)="") D IV G %RES
        S NEWN=$P(%X,".",1),NEWV=$P(%X,";",2),NEWT=$P($P(%X,".",2),";",1)
        I NEWT="" S NEWT="SOU"
        I NEWV="" S NEWV=1 I $D(^[UCI,VOL]PRG(NEWT,NEWN))#2 S NEWV=^(NEWN)+1
        I $D(^[UCI,VOL]PRG(NEWT,NEWN,NEWV)) W !,"Version # ",NEWV," already exists",!,"Specify another file version",! G %RES
%SAV    S I="" F %I=0:0 S I=$O(^PRG(OLDT,OLDN,OLDV,I)) Q:I=""  D
        .S ^[UCI,VOL]PRG(NEWT,NEWN,NEWV,I)=^PRG(OLDT,OLDN,OLDV,I)
        I $D(^[UCI,VOL]PRG(NEWT,NEWN))#2 S:NEWV>^(NEWN) ^(NEWN)=NEWV
        E  S ^[UCI,VOL]PRG(NEWT,NEWN)=NEWV
        S $P(^[UCI,VOL]PRG(NEWT,NEWN,NEWV,2),$C(9))=NEWN
        W !,%NAM," - copied to ",NEWN,".",NEWT,";",NEWV," in [",UCI,",",VOL,"]" G %G2
IV      W !,"Invalid response - Type ? for more help" Q
PRGTST  W !,"Error accessing the program global (^PRG) - ",$ZE,! G UCI
END     K %UTILITY,%D,%G,%IOD,%ZIOD,%DTY,%B,%N,%HEAD,%NG,OLDN,OLDV,OLDT,NEWN,NEWT,NEWV,UCI,VOL
        Q
