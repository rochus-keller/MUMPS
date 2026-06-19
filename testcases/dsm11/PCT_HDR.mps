%HDR    ;Routine to output block headers : JEC ;  24-NOV-80  1:25 PM
        I '$D(STR) W !!!,"The variable STR must be defined with a header string",!! Q
        I '$D(%HEADER) S %HEADER="F"
        Q:%HEADER="N"  I %HEADER="S" W #!!!,STR,!!!,"Created on " D ^%D W "    " D ^%T W !!# Q
        S %FS="ABCDEFGHIJKLMNOPQRSTUVWXYZ 0123456789,-/.!#'$()*+?\=^&%",%ST=STR,%LC=11,(ERA,%T8)=0 S:'$D(%CP) %CP=2 S:'$D(%DV) %DV=0        I %DV<63,%DV>58 U %DV
BEG     S %TM=STR W # D HDR:%LC'=7 G TIM:%TM'="",B2:%LC=7
B1      W !!!!,"Created on " D ^%D W "    " D ^%T W ! W:%DV>58&(%DV<63) "@@",!
B2      S STR=%ST,%DV=$I Q:%LC=7  S %CP=%CP-1 G BEG:%CP>0 W # G B3
        I %DV>58,%DV<63 W "@@",!
B3      I %DV>58,%DV<63 W "@@@@",!
        Q
TIM     S STR=$P(%TM," ",1) I $L(STR)>%LC S %TM=$E(%TM,%LC+1,$L(%TM)) G T2
        I $L(STR)<%LC S STR=STR_" "_$P(%TM," ",2)
        I $L(STR)>%LC S STR=$P(STR," ",1) G T1
        G T1:%LC=7
        I $L(STR)<%LC S STR=STR_" "_$P(%TM," ",3)
        I $L(STR)>%LC S STR=$P(STR," ",1)_" "_$P(STR," ",2)
T1      S %TM=$E(%TM,$L(STR)+2,$L(%TM))
T2      S STR=$E(STR,1,%LC),%L9=%LC-$L(STR) G T3:%L9'>0 F %T8=1:1:%L9 S STR=STR_" "
T3      W !!! S %L9=$L(STR),%T8=0 D ^%HDR1 S ERA=0 G B1:%TM="",TIM
HDR     F %I9=1:1:44 W "* *"
        Q
%IO     S %B=$V($V($V(44)+8)+%IO)#256,%C=$J*2 I %B=%C!'%B D SDP
        K %B,%C
        Q
SDP     I %IO>58,%IO<63 O %IO:(0:0) U %IO
        E  O %IO U %IO
        I $D(%IO)>0
        Q
Z       P %HDR ZS %HDR
