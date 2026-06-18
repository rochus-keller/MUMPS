UTL     ;FDN;13-JUN-80;UTILITY ROUTINE USED BY ^DDR
        S %QTY=2 K %DEF D ^%IOS G:'$D(%IOD) EXIT S $ZE="ERR^UTL"
1       S TXT(4)="1st hardware register",TXT(14)="CONDIO/STATUS"
        U 0 R !,"Installation name > ",WHO:60 S:'$T WHO="" G:WHO=""!(WHO="^") EXIT I WHO="?" D IQ G 1
        W !,"Beginning report.....",! U %IOD
RUN     S H=0,%ST=$V(44),%DEVT=$V(%ST+8),%=$V(%ST+10),%2=1,OFF=0,LIM=19 D PDDB S %=$V(%ST+20),%2=0,OFF=63,LIM=128 W # D PDDB
        W !!,"END",!# U 0 W !,"End of DDB print",! G EXIT
PDDB    D HEAD
        F I=1:1:LIM I $V(I+OFF+%DEVT)#256'=255 D DDBHD F J=0:2:30 D OCT
        Q
OCT     S %DO=I-1*32+J+%,%OD=%DO D %DO S ADD=%DO,%DO=$V(%OD),%DEC=%DO D %DO,%BIN W !,ADD,"(",$J(%OD,6),") :",$J(%DO,8),$J(%AN,25) I
J<20 W ?50 D TYP+J\2
        Q
%DO     S %B=%DO,%DO=""
A       S %DO=%B#8_%DO,%B=%B\8 I %B<8 S:%B %DO=%B_%DO K %B Q
        G A
%BIN    S %AN="",%Y=$V(%OD)
        F %I=1:1:18 S %AN=%Y#2_%AN,%Y=%Y\2 S:'(%I#3) %AN=" "_%AN
        Q
HEAD    I H=0 W #!,"Listing of DDB at installation ",WHO,!,"On " D ^%D W "  at " D ^%T S H=1
        S %STR=$S(%2:"Single line interfaces & special devices",1:"Multiplexor devices")
        W !!!,%STR,! F %I=1:1:$L(%STR) W "="
        Q
DDBHD   S %I="DDB for device "_(I+OFF) W !!!,%I,! F %J=1:1:$L(%I) W "-"
        W ! Q
CONDIO  I '%DEC W "No status" Q
        S %TXT=$P($T(ME)," ",2,256) F %I=0:1:15 D CPT
        Q
CPT     I '(%I#4) W !?5
        E  W ?((%I#4)*19+5)
        W "Bit ",%I,"=",$P($P(%TXT,";",%I+1),",",%DEC#2+1) S %DEC=%DEC\2 Q
        Q
ME      Echo,Non-echo
TYP     W "JSR instruction" Q
        W "Addr of Intrpt Serv Rtn" Q
        W "1st h'war reg of device" Q
        W:%DEC\8#4&(%DEC\128#128) "DMA device" Q
        Q
        W %DEC#256," margin" Q
        W %DEC#256," $X          ",%DEC\256," $Y" Q
        D CONDIO Q
        W %DEC#256," Input buffer size,    ",!?50,%DEC\256," Pointer to nxt char in buff." Q
        W %DEC#256," Pointer to nxt char out from input buff,    ",!?50,%DEC\256," Input char cnt"
        Q
IQ      W !?5,"Enter your installation's name.",!?5,"It will be used for the report heading.",! Q
ERR     U 0 I $ZE?1"<INRPT".E W !?5,*7,"Unexpected interrupt",!,*7
        E  W !,*7,$ZE,!
EXIT    U 0 I $D(%IOD) C:%IOD'=$I %IOD
        K %,%2,%AN,%DEC,%DO,%DEVT,%DEVTY,%I,%IOD,%J,%OD,%ST,%STR,%TXT,%Y,ADD,H,I,J,LIM,OFF,TXT,WHO Q
