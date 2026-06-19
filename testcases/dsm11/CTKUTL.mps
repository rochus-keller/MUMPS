CTKUTL  Q  ;CARETAKER UTILITY ROUTINES;DB;DEC 80
ZUSE    ZU $V(ST+346)#256:(:::::32) W *7,*7,!!,"***  " D H^CTKDAT W "  Caretaker message  ***",! Q
ERRP    D ZUSE I RTYCT<500 W "Unrecovered" G ERR1
        W:DEV'="DU" "Recovered"
ERR1    W " error on device ",DEV,U I B W " at DSM block ",B
        W " D ^KTR for full report ***",! Q
CLR     V ST+360::0
        Q
ERR     S ZE=$ZE,$ZT="ERR2" ZU $V(ST+346)#256:(:::::32) W !!,ZE
        I ZE["DKHER" S MPMS=$V(ST+205)*65536+$V(ST+206) I MPMS W " at block ",MPMS," on ",$C($V(ST+208)#256),$C($V(ST+209)),$C($V(ST+210)#256+48)
        G TEST^CTK0
ERR2    I $V(ST+204)\8#2 H TIM G ERR
        H
        Q
GETH    S CURH=$H I CURH=OLDH S SEQ=SEQ+1,CURH=CURH_"."_SEQ
        E  SET OLDH=CURH,SEQ=0
        Q
