%GGP    ;1-Apr-85 ;DSM11 ;UTILITIES ;GET GLOBAL POINTER ;RWB
%GGP    ;
        W !,?10,"GET GLOBAL POINTER",!
        R !,"ENTER UNSUBSCRIPTED NAME OF GLOBAL: ",%GNAME
        S %FLAG="FROM THE BEGINNING"
        G %CONT
%START  ;
        I '($D(%FLAG)) S %FLAG="NOT"
        G %CONT1:(%FLAG="FGC")!(%FLAG="FGR"),%CONT
%MAP    NEW (%GNAME,%UCIN,STR,%PROT,%KILL) S %FLAG="MAP"
        S %UCI=$P($ZU(%UCIN,STR),",",1),%SYS=$P($ZU(%UCIN,STR),",",2)
        G %CONT2
%CONT   O 63::0 E  W !,"VIEW BUFFER NOT ACCESSIBLE",! G %END1
%CONT1  D ^%GUCI
%CONT2  S %UCIN=$P($ZU(%UCI,%SYS),","),%STB=$V(44),%UCNUM=%UCIN-1*20
        Q:%FLAG="S"
        S %MM=$V($P($ZU(%UCI,%SYS),",",2)*($V(%STB+34)#256)+$V(%STB+12)+2)
        S %BLK=$V(%UCNUM+4,%MM)#256*65536+$V(%UCNUM+2,%MM)
        S %S="S"_$P($ZU(%UCI,%SYS),",",2)
%VIEW   V %BLK:%S
        S %FIN=$V(1022,0),%NAM="",%PT=0
%NXT    G %PTR:%FIN'>%PT
%C      S %A=$V(%PT,0)#256,%PT=%PT+1,%NAM=%NAM_$C(%A\2) G %C:%A#2
        G %ACCT:%GNAME=%NAM
        S %PT=%PT+8,%NAM="" G %NXT
%PTR    S %BLK=$V(1016,0)#256*65536+$V(1014,0) I %BLK G %VIEW
        I %FLAG="MAP" S %GNAME="" Q
        U 0 W !,"GLOBAL NOT FOUND"
        S %GLBPTR=""
%END    ;
        C:(%FLAG'="FGC")&(%FLAG'="FGR") 63
%END1   I %FLAG="FGC" K %LAST G %ENDF
        K %UCI,%SYS,%UCNUM,%MM,%BLK,%FIN,%NAM,%PT,%A
        K:%FLAG="FROM THE BEGINNING" %UCIN,%S,%GLBPTR,%LAST,%GNAME
        K:%FLAG'="FGR" %LAST
        K:(%FLAG'="FGR")&(%FLAG'="FGC") %STB
%ENDF   K %FLAG
        Q
%ACCT   ;
        S %GFINP=%PT+5,%GFINB=%BLK,%GFINQ=%PT+1
        I %FLAG'="MAP" G %ACCT1
        I %GFINQ#2 V %GFINQ-1:0:%PROT*256+($V(%GFINQ-1,0)#256)
        E  V %GFINQ:0:$V(%GFINQ+1,0)*256+%PROT
        V -%BLK:%S
        I %KILL K @("^["""_%UCI_""","""_%SYS_"""]"_%GNAME)
        Q
%ACCT1  S %GLBPTR=$V(%PT+5,0)#256
        S %GLBPTR=%GLBPTR+(256*($V(%PT+6,0)#256))
        S %GLBPTR=%GLBPTR+(65536*($V(%PT+7,0)#256))
        S %MM=$V($P($ZU(%UCI,%SYS),",",2)*($V(%STB+34)#256)+$V(%STB+12)+4)
        S %LAST=($V(0,%MM)-1)*400+399
        I %FLAG="FROM THE BEGINNING" D %OUT
        G %END
        Q
%OUT    U 0 W !,"THE VOLUME DISK ADDRESS OF THE FIRST POINTER NODE OF THE"
        W !,"GLOBAL ",%GNAME," IS ",%GLBPTR,", AND THE NUMBER OF BLOCKS"
        W !,"IN THE VOLUME SET ",%S," IS ",%LAST,"."
        W !!
        Q
