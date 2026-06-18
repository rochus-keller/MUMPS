DPBEGIN ;7-Apr-83 ;UTILITIES ;INSTALLATION AND DISK DEFINITIONS ;JBH
        Q
DISKENT ;
TAPENT  ;
WHICH   S M=0,MAPS=4,PRM="Install DSM-11" C 63 O 63 D GETYU
        I '$D(%A) G WHICH
        I %A=1,$P(%D," ",6)="N" G WHICH
        S %UPG=0 I VER'["DSM11" G NXTP
        W !,DDU," now holds a ",$E(VER,1,8)
        I MB="B" W " backup disk." D SHLAB G NOUPG
        I $V(0,0)'=160 W " disk that's not a system disk." D SHLAB G NOUPG
        W " system disk." D SHLAB I VER["V2" G V2UP
        S QUES="V3UP"
        D ASKYN G:'$D(Y) WHICH I Y S %UPG=3,%MP=$V(812,0) G NXTP
NOUPG   S QUES="CLOB" D ASKYN I $D(Y),Y G NXTP
        W !,$ZV," installation aborted.",!,"Exit"
H       B 0 G H
CLOB    W "Do you wish to proceed with installation, overwriting ",DDU Q
CLOBH   W !,"All the data on ",DDU," will be erased by the ",$ZV,!
        W "installation procedure.  Answer 'N' (for NO) if you wish to stop now.",! Q
SHLAB   W !,"With volume label: """,%LB,"""" Q
NXTP    K (%LOAD,%LABEL,DDU,TYU,%D,%DT,%UPG,SYDDU,ST,%TY,%MP,MAP,MAPS,SYTYU)
        S $ZT=%LABEL X %LOAD
ASKYN   W ! D @QUES R " ? [Y/N]  > ",Y,!
        I Y="^" K Y Q
        I "YN"[$E(Y,1)&$L(Y) S Y=$E(Y,1)="Y" Q
        D HELP G ASKYN
HELP    S HROU=QUES_"H" D:$L($T(@HROU)) @HROU Q
V3UP    W "Do you wish to upgrade your DSM-11 Version 3 system to ",$ZV Q
V3UPH   W "If you wish to copy a new ",$ZV," system image and new system "
        W !,"utilities, but preserve other routines and globals, answer 'Y'"
V3UPH1  W !,"Answer 'N' if you wish to re-initialize the disk and erase all"
        W !,"previously existing routines and globals." Q
V2UP    W "You cannot upgrade your DSM-11 Version 2 system directly to ",$ZV
        W !,"You must first upgrade to Version 3.0, using a Version 3.0 kit." G CLOB
DDU     I $D(DSK(D)) S DDU=$P(DSK(D)," ",3)_(D#8) Q
        S D="" Q
GETYU   S %A=1,N=0 I '$D(DSK) D DSK
        S D="" F I=1:1 S D=$O(DSK(D)) Q:D=""  I $P(DSK(D)," ",5)'<MAPS D DDU S D(DDU)=D,N=N+1
        I N=0 W "Usable disk units are nil. " K %A Q
        I N=1 S DDU=$O(D("")) W "The only usable disk unit is ",DDU G TEST
ANS     W !,PRM," on which disk unit " R "? > ",DDU
        I DDU="^"!(DDU="") K %A Q
        I $D(D(DDU)) Q:$D(%QUERY)  G TEST
        W !,"Possible units are:" S D="" D  F I=2:1:N D
        .S D=$O(D(D)) W ?21,D," (",$P(DSK(D(D))," ",2)," unit ",D(D)#8,")",!
        W !,"Type the 2-character controller type, and the unit number, like this:"
        W !,"""DK0"" for RK05 unit 0, or ""^"" to go back.",! G ANS
TEST    S TYU=D(DDU),%DT=4*TYU+DTBL,%D=DSK(TYU),(VER,%LB,MB)=""
        S %TY=$P(%D," ",4),%MP=$P(%D," ",5)
        U 63:(::"CTZ") V 0:DDU S ZA=$ZA U 63:(::"C"),0
        I ZA\64#2 S QUES="NOTRDY" D ASKYN G ANS:'$D(Y),TEST:Y Q
        F I=882:1:897 S VER=VER_$C($V(I,0)#256)
        F I=816:1:816+21 S %LB=%LB_$C($V(I,0)#256)
        S MB=$C($V(814,0)#256)
        S %A=0 Q
NOTRDY  W !,"Unable to access block 0 on ",DDU,".  Try again" Q
NOTRDYH I $P(DSK(TYU)," ",6)="Y" G FORMAT
        W !,"The disk must be off-line. Please make it ready." Q
FORMAT  W !,DDU," may need to be 'formatted' if it has never been used before."
        W !,"In that case, answer 'N', and we'll proceed without reading block 0."
        W !,"Answer 'Y' if it is already formatted, but was just off-line." Q
TYPES   S TYPES="DK,DM,DR,DB,DL,DU" Q
%DDU    K %DT I DDU'?2A1N S %D="" Q
        D TYPES S %D=$F(TYPES,$E(DDU,1,2))\3-1 I %D="" Q
        I $E(DDU,3)>7 S %D="" Q
        S %DT=%D*8+$E(DDU,3)*4+$V($V(44)+224)
        S %D=$V(%DT)#256
%D      I %D<1!(%D'?.N) S %D="" Q
        S %D=$T(@%D) Q
DKNAM   K DKNAM F I=1:1 S DKNAM=$T(CODES+I) Q:DKNAM=""  S DKNAM($P(DKNAM," ",2))=DKNAM
        Q
CODE    K CODE F I=1:1 S CODE=$T(CODES+I) Q:CODE=""  S CODE($P(CODE," "))=$P(CODE," ",4)_","_$P(CODE," ",2)
        Q
DSK     S DTBL=$V($V(44)+224)
        F I=0:1:63 S D=$V(4*I+DTBL) I D#256,D>16383'>M S DSK(I)=$T(@(D#256))
        Q
VARS    ;
CODES   ;
1       RK05 DK 0 6 Y N 6 02 203 R 4 127
2       RK06 DM 1 33 N Y 11 03 411 R 20 0
3       RK07 DM 1 66 N Y 11 03 815 R 20 0
4       RM02 DR 2 164 Y Y 16 05 823 R 20 0
5       RM03 DR 2 164 N Y 16 05 823 R 20 0
6       RM05 DR 2 625 Y Y 16 19 823 R 63 0
7       RM80 DR 2 303 N Y 15.5 14 559 F 20 0
8       RP04 DB 3 212 Y N 11 19 411 R 63 0
9       RP05 DB 3 212 Y N 11 19 411 R 63 0
10      RP06 DB 3 424 Y N 11 19 815 R 63 0
11      RL01 DL 4 12 N Y 10 02 256 R 10 0
12      RL02 DL 4 25 N Y 10 02 512 R 10 0
13      RA60 DU 5 500 N N 21 6 1588 R 20 0
14      RA80 DU 5 296 N N 15.5 14 546 F 20 0
15      RA81 DU 5 1113 N N 25.5 14 1248 F 45 0
16      RX50 DU 5 1 N N 5 1 80 R 0 30
17      RD51 DU 5 26 N N 9 2 600 F 0 0
18      RC25 DU 5 63 N N 15.5 7 500 R 20 0
19      RCF25 DU 5 63 N N 15.5 7 500 F 20 0
20      RD52 DU 5 75 N N 27 2 560 F 20 0
21      RD53 DU 5 172 N N 43 2 802 F 20 0
22      RD54 DU 5 390 N N 43 2 1680 F 20 0
23      RD31 DU 5 50 N N 18 2 560 F 20 0
24      RD32 DU 5 100 N N 18 4 560 F 20 0
25      RX33 DU 5 3 N N 20 2 30 R 20 0
26      RA82 DU 5 1520 N N 15.5 14 4368 F 20 0
27      RA70 DU 5 600 N N 16.5 14 1500 F 20 0
