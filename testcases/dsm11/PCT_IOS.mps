%IOS    ; GEF ; DSM UTILITIES ; I/O DEVICE SELECTOR
%INIT   S %ST=$V(44),%DT=$V(%ST+8),DDB=$V(%ST+10) K %MTM,LP
        F DEV=3:1:19 Q:$V(%DT+DEV)#256=255  D
        .I DEV=$V($V($V(44)+230)) S LP(DEV)=1 Q
        .ZU DEV I $ZA\1024#2 S LP(DEV)=1 Q
        U 0 S %QRY="Device ?" I '$D(%QTY) G %ASK
        I %QTY#100=1!(%QTY#100=2) S %QRY=$P("In^Out","^",%QTY#100)_"put "_%QRY G %ASK
%ASK    W !,%QRY W:$D(%DEF) " < ",%DEF
        R " > ",%X I %X'="",%X'="^" G %CK
        I '$D(%DEF)!(%X="^") G %KIO
        S %X=%DEF I %X S %IOD=%DEF G %OPN
%CK     I %X="?" D @$S(%QRY["Input":"%Q4",1:"%Q1^%IOS1") G %ASK
        I %X="0" S %X=$I G %GOT
        I %X?1"MT"1N S %X=47+$E(%X,3) G:%X<51 %GOT D %IV G %ASK
        I %X?1"LP" S %X=3 G %GOT
        I %X?1"SDP"1N S %X=59+$E(%X,4) G:%X<63 %GOT D %IV G %ASK
        I %X'?1N.N!(%X>255)!(%X=63) D %IV G %ASK
%GOT    S %IOD=%X
%OPN    S %T=$V(%DT+%IOD)#256 I %T=255 W "   Device not in system" G %ASK
        S %DTY="" I %IOD>58,%IOD<63 S %DTY="SDP" G %ADD
        I %IOD>50,%IOD<59 S %DTY="SDP" G %AD2
        I %IOD>46,%IOD<51 D:'$D(%MOD) %MODQ^%IOS1 G %KIO:%MOD="^" C %IOD
        I $D(%QTY),%QTY\100 G %OPN5
        I '$D(%RL) G %OPN3
        O:$D(%BLK) %IOD:(%MOD:%RL:%BLK):0 O:'$D(%BLK) %IOD:(%MOD:%RL):0
        E  W "   Device unavailable" K %DEF G %ASK
        G %OPN4
%OPN3   O:$D(%MOD)&$D(%BLK) %IOD:(%MOD::%BLK):0 O:$D(%MOD) %IOD:(%MOD):0
%OPN4   O:'$D(%MOD) %IOD::0 E  W "  Device unavailable" K %DEF G %ASK
%OPN5   I %IOD=1 S %DTY="SC" G %END
        I $D(LP(%IOD)) S %DTY="LP" G %END
        I %IOD>2,%IOD<20 S %DTY="TRM" ZU %IOD S:$ZA\8192#2 %DTY="DMC" U 0 G %END
        I %IOD>46,%IOD<51 S %DTY="MT" D %SET^%MTCHK G %END:'$D(%MTTYP)
        I %IOD>63,%IOD'>($V($V(44)+462)#256) S %DTY="TRM"
        G %END
%ADD    ;
        S %P="" I $D(^[$ZU(1,0),$P($ZU(1,0),",",2)]SYS(0,"SDP SPACE",%IOD-58)) S %P=^(%IOD-58,"START")_":0:"_^("DISK")
        W !,"Address ? " W:$L(%P) "("_%P R "> ",%X S:%X="" %X=%P I %X="?" D %Q2 G %ADD
        I %X=""!(%X="^") K %ADD G %ASK
        I %X'?1N.N1":"1N.N1":D"1U1N D %IV G %ADD
        D OPSDP G:'%X %ASK S %ZA=$ZA E  W "   Device unavailable",! G %ASK
        I %ZA<0 W !,?5,"Block not available for SDP",!! G %ADD
        G %END
%AD2    R !,"Address ? > ",%X I %X="?" D %AD2H G %AD2
        I %X=""!(%X="^") K %ADD G %ASK
        D OPSDP G:'%X %AD2 U %IOD S %ZA=$ZA U 0 G:%ZA'<0 %END
        C %IOD W !,%ZA," error on device ",%IOD,! G %AD2
OPSDP   S %P=%X,$P(%P,":")=$P(%X,":",2),$P(%P,":",2)=$P(%X,":"),%X=1
        I $P(%P,":",3)'="" S $P(%P,":",3)=""""_$P(%P,":",3)_""""
        S $ZT="OPERR" O @(%IOD_":("_%P_"):1") Q
OPERR   S %X=0 U 0 I $ZE["<PAR" W !,"Illegal ",$P("byte,block,switch,record size",",",$E($ZE,5))," specified" Q
        W !,$E($ZE,1,7)," error occurred opening device ",%IOD,! S %X=0 Q
%REW    ;
        U %IOD I @(%MTBOT_"'=0") U 0 Q
        U 0 R !,"Rewind ? <NO> ",%X I %X="?" D %Q3 G %REW
        I %X="^" K %REW G %RK
        I %X=""!($E(%X,1)="N") S %REW=0 G %RK
        I $E("YES",1,$L(%X))'=%X D %IV G %REW
        U %IOD W *5 S %REW=1
%RK     K %X,%DEF,%QRY U 0 Q
%IV     W !,?5,"Incorrect response - Enter '?' for more information." Q
%Q2     W !!,?5,"Enter an SDP address of the form:",!
        W !?11,"Blk#:Byte#:DDU"
        W !?11,"Where DDU = Disk and Unit in the form DK0, etc.",!
        Q
%AD2H   W !!?5,"Enter a block, byte address and format switch in the form:",!
        W !?11,"Blk#:Byte#:switch list"
        W !!?5,"If fixed record format has been selected, you may use an"
        W !?5,"optional 4th argument to specify record length.",! Q
%Q3     W !,?5," Enter Y(ES) or N(O)" Q
%Q4     W !!,"The only valid devices for input are SDP or magnetic tape devices."
        W !,"Enter either the mnemonic (SDP0-3 or MT0-3),",!?6,"or the device number (47-50 or 59-62)",!! Q
%KIO    K %IOD,%DTY
%END    K %MOD,%RL,%BLK,%QRY,%DEF,%QTY,%X,%DT,%ST,%T,%ZA,DDB,DEV,LP Q
