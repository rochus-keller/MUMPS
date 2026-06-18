SGSUB   ;20-Apr-83 ;UTILITIES ;SYSGEN ;GENERAL SUBROUTINES USED BY SYSGEN ;JHM
VECCSR  S QUES="VEC" S DEF=VEC
GVEC    X ^%Q("SGEN") G CSREX:%A
        I ANS'?2.3N!(ANS[8)!(ANS[9)!(ANS<120)!(ANS>770)!(ANS#2) D IV G GVEC
        S VEC=ANS
GCSR    S QUES="CSR" S DEF=CSR
GCSR2   X ^%Q("SGEN") G VECCSR:%A
        I ANS'?6N!(ANS[8)!(ANS[9) D IV G GCSR2
        I ANS>757777 S ANS=ANS-600000
        I ANS>177540 D IV G GCSR2
        S CSR=ANS
CSREX   Q
IV      W !,"   Incorrect response - enter '?' for more information",! Q
VECH    ;;7
        ;;      The VECTOR address is an octal number in the range 0 to 770 and
        ;;      is generally a multiple of 10.
        ;;
        ;;      If you do not know the VECTOR address of this hardware device,
        ;;      contact your DIGITAL FIELD SERVICE representative or use
        ;;      the AUTOCONFIGURE option of SYSGEN in baseline mode.
        ;;
        ;;
CSRH    ;;8
        ;;      The CONTROL and STATUS REGISTER (CSR) address is an octal number
        ;;      in the range of 160000 to 177540.
        ;;
        ;;      If you do not know the VECTOR address of this hardware device,
        ;;      contact your DIGITAL FIELD SERVICE representative or use the
        ;;      AUTOCONFIGURE option of SYSGEN in baseline mode.
        ;;
        ;;
VEC     ;;0;;;;1
        W !,?4,"Enter the VECTOR address, in OCTAL, for ",FOR Q
CSR     ;;0;;;;1
        W ?4,"Enter the CSR address, in OCTAL, for ",FOR Q
