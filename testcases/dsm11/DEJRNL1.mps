DEJRNL1 ;YZH;23-JUN-80;INPUT DEVICE SELECTOR FOR DEJOURNAL FROM MAGTAPE
        W !!,"Journal Global Restore from magnetic tape"
%ASK    S %ST=$V(44),%DT=$V(%ST+8)
        R !!,"Input device ? > ",%X I %X=""!(%X="^") G %JGR^DEJRNL
        I %X="?" D %Q1 G %ASK
        I %X?1"MT"1N S %X=47+$E(%X,3) I %X>50 D %IV G %ASK
        I %X'?1N.N!(%X>50)!(%X<47) D %IV G %ASK
        S %JIO=%X
        S %T=$V(%DT+%JIO)#256 I %T=255 W "   Device not in system" G %ASK
        I %JIO=47,%T=250 W "   Device in use for Journaling" G %ASK
        C %JIO O %JIO:"CAVUT":0 E  W "   Device unavailable" G %ASK
        U %JIO D %SET^%MTCHK G %DONE:'$D(%MTTYP)
        U %JIO I @(%MTON_"=0") U 0 W !,"Drive not ready" G %DONE
        I @(%MTWLK_"=0") U 0 W "  ** Tape is not write protected **"
        I @(%MTBOT_"=0") U 0 D %REW I '$D(%REW) G %DONE
        G ^DEJRNL2
%REW    R !,"Rewind ? <NO> ",%X I %X="?" D %Q2 G %REW
        I %X="^" K %REW Q
        I %X=""!(%X="N")!(%X="NO") S %REW=1 Q
        I $E("YES",1,$L(%X))'=%X D %IV G %REW
        U %JIO W *5 S %REW=1 U 0 Q
%DONE   U 0 C:%JIO'=$I %JIO G %ASK
%IV     W !,?5,"Incorrect response.  Enter '?' for more information" Q
%Q1     W !!,?5,"Enter valid magnetic tape device # (47-50) or mnemonic (MT0-3)",! Q
%Q2     W !,?5,"Enter Y(es) or N(o)",! Q
Z       P DEJRNL1 ZS DEJRNL1 Q
