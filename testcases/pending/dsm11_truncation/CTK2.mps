CTK2    Q  ;CARETAKER ERROR MESSAGE PRINTER;DB;DEC80
RDK     W "Recoverable disk write error - disk off-line or write protected - retrying **",! Q
HDK     W "Disk write error - write aborted - D ^KTR for full report **",! Q
JRN     I $V(ST+410)\64#2 W "Journal out of space" G JRN1
        I $V(ST+410)\128#2 W "Journal magtape error"
        I $V(ST+410)\1024#2=0 G JRN1
        W "Journal interrupted"
        V ST+410::$V(ST+410)-($V(ST+410)\1024#2*1024)+($V(ST+410)\128#2=0*128)
JRN1    W " - D ^JRNRECOV to recover and continue. **",! Q
DKRES   W "Disk full early warning **",! Q
DBOVF   W "Database overflow error **",! Q
LPER    D ZUSE^CTKUTL W "Error on output-only device ",DEV,", please make device ready and it will resume.",! Q
ERR     S ZE=$ZE,$ZT="ERR2" ZU $V(ST+346)#256:(:::::32) W !!,ZE
        I ZE["DKHER" S MPMS=$V(ST+205)*65536+$V(ST+206) I MPMS W " at block ",MPMS," on ",$C($V(ST+208)#256),$C($V(ST+209)),$C($V(ST
+210)#256+48)
        G TEST^CTK0
ERR2    I $V(ST+204)\8#2 H TIM G ERR
        H
