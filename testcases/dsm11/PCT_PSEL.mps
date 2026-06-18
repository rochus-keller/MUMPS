%PSEL   ;2-Dec-81 ;UTILITY ;PROGRAM MAINTENANCE ;PROGRAM NAME SELECTOR ;JHM
        K ^UTILITY($J) S %GO=0
%ASK    R !,"Program(s)> ",%ROU I %ROU="" S:$D(^UTILITY($J)) %GO=1 Q
        I %ROU="^" S %GO=0 Q
        I %ROU="^L" D %LST G %ASK
        I %ROU="?" D HELP G %ASK
        D %EXT G %ASK
%EXT    I $P(%ROU,".",2)="" S %ROU=%ROU_".SOU"
        I $E(%ROU,1)="-" S %DEL=1
        E  S %DEL=0
GETPRG  ;
        I %DEL S %ROU=$E(%ROU,2,999)
        D %GET I '%CT W ?30,"-  no programs found"
        G %PSELX
%GET    S %VR=$P(%ROU,";",2),%PN=$P(%ROU,".",1),%TP=$P($P(%ROU,".",2),";",1),%CT=0
        S A=%TP D PATC S TPAT=PAT,TBEG=BEG,TCHR=FCHR
        S A=%PN D PATC S PPAT=PAT,PBEG=BEG,PCHR=FCHR
        S %TYP=$N(^PRG(TBEG)) I TBEG=-1 S FN="" Q
%TYP    I @("%TYP"_TPAT) D %PNM
        S %TYP=$N(^PRG(%TYP))
        I %TYP=-1!($E(%TYP,1,$L(TCHR))'=TCHR) S FN="" Q
        G %TYP
%PNM    S %PNM=$N(^PRG(%TYP,PBEG)) Q:%PNM=-1
%PNM2   I @("%PNM"_PPAT) D
        .I %VR="" S VR=^PRG(%TYP,%PNM) D %SETKT Q
        .I %VR'="*" S VR=%VR D %SETKT Q
        .I %VR="*" S VR="" F I=1:1 S VR=$O(^PRG(%TYP,%PNM,VR)) Q:VR=""  D %SETKIL
        S %PNM=$N(^PRG(%TYP,%PNM))
        I %PNM=-1!($E(%PNM,1,$L(PCHR))'=PCHR) Q
        G %PNM2
%SETKT  I '$D(^PRG(%TYP,%PNM,VR)) Q
%SETKIL S %CT=1
        I '%DEL S ^UTILITY($J,%PNM_"."_%TYP_";"_VR)=""
        E  K ^UTILITY($J,%PNM_"."_%TYP_";"_VR)
        Q
PATC    S PAT="?" I A="" S PAT=PAT_".E",(BEG,FCHR)="" Q
        I '$F(A,"*") S BEG=$E(A,1,$L(A)-1)_$C($A(A,$L(A))-1)_"{",PAT=PAT_"1"""_A_"""",FCHR=A Q
        S C=$F(A,"*"),BEG=$E(A,1,C-3)_$C($A(A,C-2)-1)_"{",FCHR=$E(A,1,C-2)
        I BEG="{" S BEG=""
PTC     S C=$F(A,"*")
        I 'C Q:A=""  S PAT=PAT_"1"""_A_"""" Q
        I $E(A,1,C-2)'="" S PAT=PAT_"1"""_$E(A,1,C-2)_""""
        S PAT=PAT_".E",A=$E(A,C,$L(A)) G PTC
%PSELX  K %CT,%TP,%VR,%PN,TPAT,TBEG,TCHR,PPAT,PBEG,PCHR,PAT,BEG,FCHR,FN,%TYP
        Q
%LST    S %NAM="",P=0 W !
%L1     S %NAM=$ZS(^UTILITY($J,%NAM)) Q:%NAM=""  W ?(P*20),%NAM S P=P+1 I P>3 W ! S P=0
        G %L1
HELP    S C=$P($T(TXT),";;",2) F I=1:1:C W !,$P($T(TXT+I),";;",2)
        Q
TXT     ;;13
        ;;Enter the name of the routine you wish to select.  You may use wild
        ;;card file specifications if you like for the filename, extension,
        ;;version, or any leading, trailing or center portion of the file
        ;;specification.
        ;;
        ;;For example:
        ;;
        ;;Routine(s) > *.SOU        selects all files with the .SOU extension
        ;;Routine(s) > *                selects all files with the .S extension
        ;;Routine(s) > T*.VAX           selects all files beginning with T and
        ;;                              containing the .VAX extension
        ;;
        ;; note:  .SOU is the default extension
