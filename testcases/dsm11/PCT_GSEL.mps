%GSEL   ;FDN;5-JUN-80;GLOBAL SELECTOR
        I '$D(%PGC) S %UCIN=$P($ZU(""),","),%SN=$P($ZU(""),",",2)
        S %ST=$V(44),%GO=1
        S %MM=$V(%SN*($V(%ST+34)#256)+$V(%ST+12)+2)
        S %DIR=$V(%UCIN-1*20+4,%MM)#256*65536+$V(%UCIN-1*20+2,%MM)
        S %VS="S"_%SN
        S:'$D(^UTILITY) ^UTILITY="" K ^UTILITY($J) U 0
%ASK    C 63 R !,"Global(s) ? > ",%X G:%X="" %END G:%X="?" %Q1 I %X="^" S %GO=0 G %END
        I %X="^D" D %LST^%GD G %ASK
        I %X="^L" D %LST G %ASK
        I %X["(" D %START^%GSEL1 G %ASK
        S (%MI,%ALL)=0 I $E(%X,1)="-" S %MI=1,%X=$E(%X,2,999)
        I %X="*" K ^UTILITY($J) G %ASK:%MI S %L=8,%ALL=1 D %GET G %ASK
        I %X?.E1"*" S %ST=$E(%X,1,$L(%X)-1),%FI=%ST,%L=$L(%ST) D @$S('%MI:"%GET",1:"%REM") G %ASK
        I %X?1E.E1"-"1E.E S %ST=$P(%X,"-",1),%FI=$P(%X,"-",2),%L=8 D @$S('%MI:"%GET",1:"%REM") G %ASK
        I '(%X?1A.AN!(%X?1"%".AN)) D %IV G %ASK
        I %MI K ^UTILITY($J,%X) G %ASK
        I '$D(%PGC) S %DCF=$D(@("^"_%X)) W:'%DCF !,*7,?8,"No such global" G:'%DCF %ASK
        I $D(%PGC) S GL=%X,%DCF=$D(@("^"_"["_""""_FUCI_""""_","_""""_FSYS_""""_"]"_%X)) W:'%DCF !,*7,?8,"No such global" G:'%DCF %ASK D:%PGC %WAN
        S ^UTILITY($J,%X)="" G %ASK
%GET    S %BLK=%DIR O 63::0 E  W !?5,"View Buffer busy" Q
        W !,"Searching directory..."
%G1     V %BLK:%VS
        S %END=$V(1022,0),%NAM="",%PT=0
%NXT    G %PTR:%END'>%PT
%C      S %A=$V(%PT,0)#256,%PT=%PT+1,%NAM=%NAM_$C(%A\2) G %C:%A#2
        G %SAV:%ALL S %T=$E(%NAM,1,%L)
        I '(%T=%ST!(%T]%ST)&(%T']%FI)) G %MOR
%SAV    S ^UTILITY($J,%NAM)=""
%MOR    S %PT=%PT+8,%NAM="" G %NXT
%PTR    S %BLK=$V(1016,0)#256*65536+$V(1014,0) I %BLK G %G1
        K %A,%NAM,%PT,%BLK,%END Q
%REM    K ^UTILITY($J,%ST) S %N=%ST
%R1     S %N=$O(^(%N)) I %N="" Q
        S %T=$E(%N,1,%L)
        I %T=%ST!(%T]%ST),%T']%FI K ^(%N) G %R1
        Q
%WAN    I $D(@("^"_%X)) W !,"** Global ^",%X," already exists in your UCI.  Enter '^' if you want to abort **",!
        Q
%IV     W !,?5,"Incorrect response - Enter '?' for more information" Q
%LST    S %A="",%J=0 I $D(^UTILITY($J,1))
%L1     S %A=$O(^(%A)) I %A=""&($D(%I)) K %A,%J Q
        I %A=""&('$D(%I)) D %NONE Q
        W:'(%J#8) ! W ?(%J#8*10),%A S %J=%J+1,%I=1 G %L1
%Q1     W !!,?5,"Enter   A global name"
        W !,?8,"or   A partial global reference with subscripts"
        W !?13,"where subscripts may be:"
        W !,?15,"Value:  AA(3,5,7   or  AA(DEC,SMITH,25"
        W !,?15,"Range:  AA(3,5-12,7   or  AA(DEC,A-K,25"
        W !,?15,"Null string (All subscripts on that level):  AA(3,,7"
        W !,?15,"With right parenthesis (Values at this level only and"
        W !,?17,"nothing below):  AA(3,,7)  or  AA(DEC,,25)"
        W !,?8,"or   NAM*       For all globals beginning with the letters 'NAM'"
        W !,?8,"or   NAM1-NAM2  To select globals whose names are in the range"
        W !,?24,"from NAM1 to NAM2, inclusive"
        W !,?8,"or    *    To select all globals"
        W !,?8,"or    -    Followed by any of the above to de-select globals"
        W !,?19,"which have been selected"
        W !,?8,"or    ^L   To list selected globals"
        W !,?8,"or    ^D   To list your global directory"
        W !,?8,"or   <CR>  When done selecting"
        W !,?8,"or    ^    To terminate without selection",!! G %ASK
%NONE   W !?5,*7,"No globals selected" Q
%END    C 63 K %X,%FI,%MI,%DIR,%UCI,%ALL,%L,%N,%T,%X1,%X2,%PIE I '$D(^UTILITY($J)) K %GO D %NONE
        Q
