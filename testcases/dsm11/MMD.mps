MMD     ;RLW; MODIFY MAGTAPE DEFAULT MODE
        D ID^SYSROU Q:ID="^"  D SYSGEN,^MDAT Q
SYSGEN  D SETYP I '$D(^SYS(ID,"MT")) Q:SGN  W !,"No magtape units on this system" Q
        S TY=^("MT") I 'TY Q:SGN  W !,"No magtape units on this system" Q
        W !!,"******* Modify magtape default mode *******",!
        S ST=$V(44)
        S MTB=$V(ST+22)+4
LOOP    F J=0:1:TY-1 W !!,"Mag tape unit ",J D ONE
        G EXIT
ONE     S (DS,LB,AE,FO,DN)=""
        D CMODE
MOD     S MOD="N" R !!,"Modify magtape default mode <N> ",MO Q:MO=""!(MO="^")!(MO="N")  I MO["?" D HLP G MOD
        I MO'="Y" W !!?5,"Enter ""Y"" or ""N""" G MOD
DOS     S:DS="" DS="N" S DEF=DS W !,"DOS-11 compatible format? (Y or N) <",DEF R "> ",DS S:DS="" DS=DEF
        I DS="^" S DS=DEF G MOD
        I "Y"[DS G TY
        I "YN"'[DS W !,"Enter 'Y' or 'N'" S DS=DEF G DOS
CHR     S:AE="" AE="A" S DEF=AE W !,"ASCII or EBCDIC (type A or E) <",DEF R "> ",AE S:AE="" AE=DEF
        I AE="^" S AE=DEF G DOS
        I "AE"'[AE W !,"Enter 'A' or 'E'" S AE=DEF G CHR
LAB     S:LB="" LB="L" S DEF=LB W !,"Labelled or Unlabelled (type L or U) <",DEF R "> ",LB S:LB="" LB=DEF
        I LB="^" S LB=DEF G CHR
        I ("LU"[LB=0) W !,"Enter 'L' or 'U'" S LB=DEF G LAB
FMT     S:FO="" FO="S" S DEF=FO W !,"Stream, Fixed or Variable record format (type S, F, or V) <",DEF R "> ",FO
        S:FO="" FO=DEF
        I FO="^" S FO=DEF G LAB
        I ("FSV"'[FO) W !,"Enter 'S', 'F' or 'V'" S FO=DEF G FMT
TY      I MUTYP_TMTYP[^SYS(ID,"MT",J,"TYPE") S DN=800 G SET
        I TSTYP[^("TYPE") S DN=1600 G SET
DEN     S:DN="" DN=800 S DEF=DN W !,"Density (800, 1600, or 6250) <",DEF R "> ",DN S:DN="" DN=DEF
        I DN="^" S DN=DEF G FMT
        I ^SYS(ID,"MT",J,"TYPE")="TU81" G:DN=6250!(DN=1600) SET W !,DN," not allowed for TU81." S DN=DEF G DEN
        I (DN=800!(DN=1600)=0) W !,"Enter '800' or '1600'" S DN=DEF G DEN
SET     I DS="Y" S FO="S",AE="",LB=""
        S D=(DN=1600*32) I ^SYS(ID,"MT",J,"TYPE")="TU81" S D=(DN=6250*32)
        S CODE=D+(DS="Y"*16)+(LB="L"*8)+(FO="F"*4)+(FO="S"*2)+(AE="E"*1)
        I DMB'="D",$V($V(ST+8)+J+47)#256'=255 V MTB+20+(J*$V(ST+298))::$V(MTB+20+(J*$V(ST+298)))#256+(CODE*256)
        S ^SYS(ID,"MT",J,"DEFAULT MODE")=AE_FO_LB,^SYS(ID,"MT",J,"DEFAULT CODE")=CODE
        S ^SYS(ID,"MT",J,"DEFAULT DENSITY")=DN S:DS="Y" ^("DEFAULT MODE")="D"
        Q
CMODE   W !!,"Current magtape default mode is:" I DMB="D" G DISK
        I DMB'="D" S BYT=$V(MTB+21+(J*$V(ST+298))),TYBYT=$V(MTB+32+(J*$V(ST+298)))
        E  S BYT=^SYS(ID,"MT",J,"DEFAULT CODE"),TYPE=^("TYPE")
        I BYT\16#2 W !,"DOS compatible, " S DS="Y" G CDN
        W ! I BYT#2 W "EBCDIC, " S AE="E"
        E  W "ASCII, " S AE="A"
        I BYT\8#2 W "Standard Label, " S LB="L"
        E  W "Unabelled, " S LB="U"
        I BYT\4#2 W "Fixed length records, " S FO="F"
        E  I BYT\2#2 W "Stream data format, " S FO="S"
        E  W "Variable length records, " S FO="V"
CDN     S DN=1600 I TYBYT=8 S:BYT\32#2 DN=6250
        E  I BYT\32#2=0 S DN=800
        W DN," BPI" Q
        W "800 BPI" S DN=800
        Q
IV      W !!?5,"Incorrect response, enter '?' for more information",! Q
HLP     W !!,"Modification options -",! F I=1:1:6 W !,$T(OPT+I)
        Q
OPT     ;
        Character set - A(SCII) or E(BCDIC)
        Format        - S(TREAM) OR V(ARIABLE) OR F(IXED) length records
        Labelling     - L(abelled) or U(nlabelled)
        Density       - 800 or 1600 BPI
        DOS-11 compatible -- ASCII characters, DOS labelling,
        and STREAM format
DISK    S TYPE=^SYS(ID,"MT",J,"TYPE")
        I ^SYS(ID,"MT",J,"DEFAULT MODE")="D" W !,"DOS compatible, " S DS="Y" G CDN1
        I $E(^("DEFAULT MODE"),1,1)="E" W !,"EBCDIC, " S AE="E"
        E  W !,"ASCII, " S AE="A"
        I $E(^("DEFAULT MODE"),3,3)="U" W "Unlabelled, " S LB="U"
        E  W "Standard labelling, " S LB="L"
        I $E(^("DEFAULT MODE"),2,2)="V" W "VARIABLE LENGTH records, " S FO="V"
        E  W "STREAM data format, " S FO="S"
CDN1    I ^SYS(ID,"MT",J,"DEFAULT DENSITY")=6250 W "6250 BPI" S DN=6250 Q
        I ^SYS(ID,"MT",J,"DEFAULT DENSITY")=1600 W "1600 BPI" S DN=1600
        E  W "800 BPI" S DN=800
        Q
SETYP   S RHTYP="TE16/TU16/TU45/TU77/",TMTYP="TS03/TU10/",TSTYP="TS11/TSV05/TU80/",MUTYP="TK50",T81TYP="TU81" Q
SETDEF  S DS="Y",DMB="D"
        S MTB=$V(ST+22)+4
        F J=0:1:^SYS(ID,"MT")-1 I '$D(^SYS(ID,"MT",J,"DEFAULT")) S DN=1600 S:TMTYP[^("TYPE") DN=800 D SET
EXIT    K TY,MTB,DS,LB,FO,J,AE
        Q
TU10    ;;800
TS03    ;;800
TE16    ;;800;;1600
TU16    ;;800;;1600
TU77    ;;800;;1600
TU45    ;;800;;1600
TS11    ;;1600
TU80    ;;1600
TK25    ;;1600
TSV05   ;;1600
TK50    ;;800
TU81    ;;1600;;6250
