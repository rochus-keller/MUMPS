%PCOMP  ;4-Dec-81 ;UTILITY ;EDITOR ;COMPILES A SINGLE PROGRAM ;JHM
        S $ZT="ERROR",BD=0
        D OPSRC I NOP G EXIT
        K TAG,STACK S (CMCT,VAR,STACK)=0,IF=1
        D GETLN,WRTLN
READLN  D GETLN
        I LINE=$C(26) D MACLS G STOR:END,READLN
        I $E(LINE,1)=";" G READLN
        S P=$F(LINE,";") I 'P G CLNLN
        I $E(LINE,P)=";" S P=$F(LINE,";",P+1) G GETC:P D SYMCHK,WRTLN G READLN
        I $E(LINE,P)=":" D MACOP G READLN
GETC    D STRCOM
CLNLN   D STRPEND
        I LINE="" G READLN
        I $E($P(LINE,$C(9),2),1)="_" D CMDCHK G READLN
        I LINE'[$C(9) S LINE=LINE_$C(9)_";"
        D TAGCHK
        D SYMCHK
        D ARGCHK
        D WRTLN G READLN
ERROR   ;
        I $ZV["VAX",$ZT'="ERROR" ZQ
        S ZE=$ZE,$ZE="" D COMPERR^%PCR G EXIT
STOR    S $ZT="STORERR^%PCOMP",ROUT=$P(PNAM,".",1)
        I CMCT D CMERR^%PCR G EXIT
        S A=-1 X "ZR  F I=0:1 S A=$N(^A($J,A)) ZS:A=-1 @ROUT Q:A=-1  ZI ^(A):+I"
        U 0 G EXIT
STORERR U 0 S ZE=$ZE,$ZE="" D STERR^%PCR G EXIT
WRTLN   ;
        S ^A($J,SCRATCH)=$P(LINE,$C(9),1)_" "_$P(LINE,$C(9),2,99999),SCRATCH=SCRATCH+1 Q
GETLN   ;
        I 'RFA S LINE=$C(26) Q
        S L=@("^PRG("_%SRC_","_RFA_")"),RFA=$P(L,"^",1),LINE=$P(L,"^",3,999)
        I 'IF D CMDCHK:($E($P(LINE,$C(9),2),1)="_") S LINE=";"
        Q
STRCOM  I $E(LINE,P)=";" S P=$F(LINE,";",P+1) Q:'P  G STRCOM
        S L=$E(LINE,1,P-2),Q=0
        F I=0:1 S Q=$F(L,"""",Q) Q:'Q
        I '(I#2) S LINE=$E(LINE,1,P-2) Q
        S P=$F(LINE,";",P) G:P STRCOM Q
STRPEND S L=$L(LINE) F I=L:-1:0 I $E(LINE,I)'=" ",$E(LINE,I)'=$C(9) S LINE=$E(LINE,1,I) Q
        Q
CMDCHK  S CM=$P($P(LINE,$C(9),2)," ",1)
        I CM="_IF" G CMIF
        I CM="_ENDIF" S CMCT=CMCT-1,IF=1 Q
        D BDCMD^%PCR Q
CMIF    S C=$P(LINE,CM,2) F I=1:1 I $E(C,I)'=" " S C=$E(C,I,99) Q
        I C'?1U.NU D BDCMR^%PCR Q
        S A=-1,IF=0 F I=0:0 S A=$N(LIB(A)) Q:A=-1  I C=LIB(A) S IF=1
        S CMCT=CMCT+1 Q
TAGCHK  I $P(LINE,$C(9),1)="" Q
        S TAG=$P(LINE,$C(9),1)
        I TAG'?."%".NU D BADTAG^%PCR Q
        I $D(TAG(TAG)) D DUPTAG^%PCR
        S TAG(TAG)="" Q
SYMCHK  I LINE'["/*" Q
        S F=0
SYM1    S F=$F(LINE,"/*",F) Q:F=0
        I '$F(LINE,"*/",F) D NODEM^%PCR
        S SYM=$P($P(LINE,"*/",1),"/*",2,3)
        I SYM["/*" D RECSYM^%PCR Q
        I SYM'?1NUP.NUP D BADSYM^%PCR G SYM1
        F I=1:1 Q:'$D(LIB(I))  I $D(^P(LIB(I),SYM)) S LINE=$P(LINE,"/*",1)_^(SYM)_$P(LINE,"*/",2,999) G SYM1
        D NOSYM^%PCR G SYM1
ARGCHK  Q:'VAR  S P=0
ARG2    S P=$F(LINE,"$$",P) Q:'P
        F E=P:1 Q:$E(LINE,E)'?1NU
        S SYM=$E(LINE,P-2,E-1)
        I '$D(VAR(SYM)) D NODEC^%PCR G ARG2
        S LINE=$E(LINE,1,P-3)_VAR(SYM)_$E(LINE,E,1000) G ARG2
MACOP   S P=$F(LINE,";",P) I P D STRCOM,STRPEND
        S P=$F(LINE,";:"),C=$F(LINE,"""") I C,C<P D WRTLN Q
        S LINE=$P(LINE,";:",2)
        I LINE'["(" D STRPEND S MACNM=LINE,ARG="" G GETMAC
        S ARG=$E(LINE,$F(LINE,"("),$F(LINE,")")-2)
        S LINE=$P(LINE,"(",1) D STRPEND S MACNM=LINE
GETMAC  I MACNM'?1U.UN D BADMAC^%PCR,REPOS,WRTLN Q
        F LIB=1:1 Q:'$D(LIB(LIB))  I $D(@("^PRG("""_LIB(LIB)_""","""_MACNM_""")")) G GOTMAC
        G MACUNDF
GOTMAC  I $P(%SRC,",",1,2)=""""_LIB(LIB)_""","""_MACNM_"""" G MACREP
        D PUSH S %SRC=MACNM_"."_LIB(LIB)_";"_@("^PRG("""_LIB(LIB)_""","""_MACNM_""")")
        D OPEN G MOPFAIL:NOP D GETLN
        S P=$F(LINE,";") D STRCOM:P
        I LINE["(" S MARG=$E(LINE,$F(LINE,"("),$F(LINE,")")-2)
        E  S MARG=""
        K VAR
VAR     F VAR=1:1 S A=$P(MARG,",",VAR) Q:A=""  S VAR(A)=$P(ARG,",",VAR) D NOVAR^%PCR:VAR(A)="",BDVAR^%PCR:A'?1"$$"1NU.NU
        I $P(ARG,",",VAR,100)'="" D EXTVAR^%PCR
        S VAR=VAR-1
        Q
MOPFAIL D MACERR^%PCR,POP,REPOS,WRTLN Q
MACUNDF D NOMAC^%PCR,REPOS,WRTLN Q
MACREP  D DUPMAC^%PCR,REPOS,WRTLN Q
MACLS   I 'STACK S END=1 Q
        D POP S END=0
REPOS   ;
        S RFA=$P(@("^PRG("_%SRC_","_RFA_")"),"^",2) D GETLN Q
POP     S %SRC=$P(STACK(STACK),"\",1),RFA=$P(STACK(STACK),"\",2)
        K VAR
        F VAR=3:1 S A=$P(STACK(STACK),"\",VAR) Q:A=""  S VAR($P(A,",",1))=$P(A,",",2)
        S VAR=VAR-4
        K STACK(STACK) S STACK=STACK-1 Q
PUSH    S STACK=STACK+1,STACK(STACK)=%SRC_"\"_RFA
        S A=-1
        F I=1:1 S A=$N(VAR(A)) Q:A=-1  S STACK(STACK)=STACK(STACK)_"\"_A_","_VAR(A)
        Q
OPSRC   ;
        S SCRATCH=1,%SRC=PNAM D OPEN,BDSRC^%PCR:NOP K ^A($J) Q
OPEN    ;
        S %SRC=""""_$P($P(%SRC,".",2),";",1)_""","""_$P(%SRC,".",1)_""","_$P(%SRC,";",2)
        I '$D(@("^PRG("_%SRC_",0)")) S NOP=1,ZE="<UNDEF>" Q
        S RFA=$P(^(0),"^",1),NOP=0 Q
EXIT    ;
        K CMCT,IF,TAG,STACK,%SRC,ERR,ZE,NOP,LINE,RFA,SCRATCH,ROUT,VAR,SYM
        G PCRETN^%PC:$D(PCFLG) Q
