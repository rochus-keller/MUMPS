%E      ;9-Dec-81 ;UTILITY ;EDITOR-COMPILER ;FRONT END FOR EDI ;JHM
        S %EDIT="^%EDI"
STRT    I '$D(%EDT(10)) S %EDT(10)="SETLIB^%P"
        K LOAD S LOAD=0
Q0      W !,"Program > " R NM I NM=""!(NM="^") Q
        I NM'["." S NM=NM_".SOU"
        S RNAME=$P(NM,".",1),EXT=$P($P(NM,";",1),".",2),VR=$P(NM,";",2)
        I '($D(^PRG(EXT,RNAME))#2) G Q1
        I VR="" S VR=^(RNAME)
        G EDIFIL
Q1      W !,"Program not found",!,"Create new program ",RNAME,".",EXT,";1 ? <Y> " R A
        I A?1"Y"."ES"!(A?1"y"."es")!(A="") G NEWFIL
        I A?1"N"."O"!(A?1"n"."o") G Q0
        I A="^" Q
        W !,"Answer yes or no" G Q1
NEWFIL  R !,"System > ",SYS G Q1:SYS="^"
Q2      R !,"Package > ",PK G NEWFIL:PK="^"
Q3      R !,"Function > ",FUN G Q2:FUN="^"
Q4      R !,"Initials > ",INI G Q3:INI="^" D INIT
EDIFIL  D INIGL,@%EDIT,INT^%D,INT^%T
        S %L=^PRG(EXT,RNAME,VR,+^PRG(EXT,RNAME,VR,+^PRG(EXT,RNAME,VR,0)))
        S ^(4)=$P(%L,"^",1,2)_"^"_$C(9)_"; Last Edit: "_%DAT1_" "_%TIM
        S ^MOD(RNAME,%DAT1,%TIM)="" Q
COM     S LIB=%A W *13
        F I=1:1 S %A=$P(LIB,",",I) D STRIP Q:%A=""  G BDLIB:%A'?1NUP.NUP S LIB(I)=%A
        S LIB(I)="COM"
        S %ERTRAP=$ZT
        I EXT="BLK" D ^%EB G COM2
        S PNAM=RNAME_"."_EXT_";"_VR K PCFLG D ^%PCOMP
COM2    S A=$D(^PRG(EXT,RNAME,VR,0)),$ZT=%ERTRAP Q
STRIP   F P=1:1 Q:$E(%A,P)'=" "  S %A=$E(%A,2,999)
        F P=$L(%A):-1:0 Q:$E(%A,P)'=" "  S %A=$E(%A,1,P-1)
        Q
BDLIB   W !,"Bad library name : ",%A Q
INIT    D INT^%D
        S VR=1,^PRG(EXT,RNAME)=VR,^PRG(EXT,RNAME,VR,0)="3^4^",^(1)="5,6,7,8,9,^10"
        S ^(3)="4^0^"_RNAME_$C(9)_";"_%DAT1_" ;"_SYS_" ;"_PK_" ;"_FUN_" ;"_INI
        S ^(2)=$P(^(3),"^",3,9999)
        S ^(4)="0^3^"_$C(9)_"; Last edit:  *****"
        Q
INIGL   S %GL="^PRG("""_EXT_""","""_RNAME_""","_VR_",",%FN="" Q
EDT     S %EDIT="^%EDT" G STRT
