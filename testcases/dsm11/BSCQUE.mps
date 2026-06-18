BSCQUE  ;29-Sep-82 ;UTILITY ;BSC ;QUEUES A FILE TO BE SENT ;JHM
STRT    W !!
Q1      S %QRY="Queue global for device " D GETDEV^BSCSTR
        G EXIT:%DEV="^"
Q2      W !,"Global ^" R %G G Q1:%G=""!(%G="^")
        I %G="?" D Q2H G Q2
        S %ZT=$ZT,$ZT="BADREF",%G="^"_%G,%A=$D(@%G),$ZT=%ZT
        I '%A W !,"Global reference undefined" G Q2
Q3      W !,"Transparent or Nontransparent data ? [T/N] > " R %M
        G Q1:%M="^",Q3:%M=""
        I %M="?" D Q3H G Q3
        I "TN"'[%M W !,"Invalid option selection - type ? for help" G Q3
        D QGLOB G Q2
EXIT    K %M,%G Q
BADREF  S $ZT=%ZT,%E=$ZE W !,"Bad global reference ",%G,"  ",%E G Q2
QGLOB   ZA ^BSCDAT(%DEV,"SEND")
        I '$D(^BSCDAT(%DEV,"SEND")) S ^BSCDAT(%DEV,"SEND")=0
        S (^("SEND"),%FN)=^("SEND")+1,^("SEND",%FN)=%M_" "_%G
        ZD ^BSCDAT(%DEV,"SEND") Q
Q2H     W !!,"Enter a complete global reference for the global you"
        W !,"wish to transmit.  The reference may only contain string"
        W !,"literals or numbers as subscripts, symbols are not allowed."
        W !,"The complete global subtree will be transmitted.  The reference"
        W !,"must be a legal global syntax.",!
        W !,"OR, enter a global name and the entire global will be transmitted"
        W !!,"Each index of the global or global subtree will be treated as"
        W !,"a record in a file.",! Q
Q3H     W !!,"Enter N if the global being transmitted contains data to be"
        W !,"treated as nontransparent (readable characters)"
        W !!,"Enter T if the global being transmitted contains data to be"
        W !,"treated as transparent (non readable binary codes)",! Q
