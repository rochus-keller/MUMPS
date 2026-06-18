SGMAGT  ;26-Apr-83 ;UTILITIES ;SYSGEN ;GET MAGTAPE INFORMATION ;JHM
        Q
START   W !,"PART 3:",?10,"SYSTEM DEVICES",!,"-------",! D SETYP^MMD
        I 'EDIT W !,"System Device information supplied by AUTOCONFIGURE",! G DONE
        S DEF=0 S:$D(^SYS(ID,"MT")) DEF=^("MT") S QUES="MTNUM" X ^%Q("SGASK") G RETURN:%A
        I ANS'?1N!(ANS>4) D IV G START
        S ^SYS(ID,"MT")=ANS F J=0:1:^SYS(ID,"MT")-1 D MTTYPE G:%A START
DONE    F K=^SYS(ID,"MT"):1:3 K ^SYS(ID,"MT",K)
        S ^SYS(ID,"OPTIONS","MAGTAPE")=$S(^SYS(ID,"MT"):"Y",1:"N")
        D SETDEF^MMD
        K VEC,CSR,RHTYP,TMTYP,TSTYP,FTYPE,TYPE,FOR,SUB,SV1,SYV
        D START^SGDEVS I %A G:EDIT START
RETURN  Q
MTTYPE  S (CSR,VEC,DEF)="",QUES="MTUNI"
        I $D(^SYS(ID,"MT",J,"TYPE")) S DEF=^("TYPE")
        X ^%Q("SGASK") Q:%A  S TYPE=ANS
        I TYPE'?2.3U2N!'$F(RHTYP_TMTYP_TSTYP_MUTYP_T81TYP,TYPE) D IV G MTTYPE
        G TYPE:'J S FTYPE=^SYS(ID,"MT",0,"TYPE")
        I TSTYP[FTYPE,T81TYP_MUTYP_TSTYP'[TYPE D IV G MTTYPE
        I TMTYP[FTYPE,T81TYP_MUTYP_TSTYP_TMTYP'[TYPE D IV G MTTYPE
        I RHTYP[FTYPE,T81TYP_MUTYP_RHTYP_TSTYP'[TYPE D IV G MTTYPE
TYPE    S ^SYS(ID,"MT",J,"TYPE")=TYPE
VEC     I $D(^SYS(ID,"MT",J,"VECTOR")) S VEC=^("VECTOR")
        E  I 'J,RHTYP_TMTYP[TYPE S VEC=224
        I $D(^SYS(ID,"MT",J,"CSR")) S CSR=^("CSR")
        E  I RHTYP[TYPE S CSR=172440
        E  I 'J,TMTYP_TSTYP[TYPE S CSR=172520
        E  I J,TSTYP[TYPE,TSTYP[^SYS(ID,"MT",0,"TYPE") S CSR=J\2*2+(J*4)+172520
        E  I 'J,T81TYP_MUTYP[TYPE S CSR=174500
        I J,RHTYP_TMTYP[TYPE S VEC=^SYS(ID,"MT",0,"VECTOR"),CSR=^("CSR") G SET
        S FOR="Tape Unit "_J D VECCSR^SGSUB G:%A MTTYPE
SET     S ^SYS(ID,"MT",J,"CSR")=CSR,^("VECTOR")=VEC
        Q
IV      W !,"   Incorrect response - enter '?' for more information",! Q
MTNUMH  ;;2
        ;;Enter the number of Magnetic Tape drives that you have on the system.
        ;;
MTUNIH  ;;11
        ;;  Enter the type of magnetic tape drive. The supported types are:
        ;;
        ;;TU80 TS03 TS11 TSV05 TU10 TE16 TU16 TU45 TU77 TK25 TK50 TU81
        ;;TK50  TU81
        ;;
        ;;  The following rules apply when configuring tape drives:
        ;;
        ;;  If unit 0 is TS11/TU80/TSV05, all units must be TS11/TU80/TSV05 or MU.
        ;;  If unit 0 is TS03/TU10, other units can be TU10/TS03, TS11/TU80/TSV05, or MU.
        ;;  If unit 0 is TE16/TU16/TU45/TU77, other units can be TE16/TU16/TU45/TU77, MU,
        ;;                                                        or TS11/TU80/TSV05.
        ;;
MTNUM   ;;1;;3.1;;1
        ;;How many Magnetic Tape Units are there (Max = 4)
MTUNI   ;;0;;3.2;;1
        W !,%NUM,?6,"What type is magnetic tape unit ",J Q
