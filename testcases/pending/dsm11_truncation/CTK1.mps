CTK1    Q  ;CARETAKER ERROR LOGGER FOR DISK AND TAPE ERRORS
        ;;modified April 2 1985 for UDA50 error logging
LOG     S DEV=$C($V(ST+208)#256)_$C($V(ST+209)#256),U=$C($V(ST+210)#256+48),ERNMB=$V(ST+214)#256,ERPKT=($V(ST+214)\256)+1,DEVERR=$V(
ST+470)
        F PKT=1:1:ERPKT S START=DEVERR+(PKT-1*ERNMB*2) D LOG1
EXIT    D ERRP^CTKUTL V (ST+160)::0,(ST+204)::8 K DEVERR,ERNMB,ERPKT,PKT Q  ;; Clear command ref. num. and EL.FUL in DKMPMS
LOG1    D GETH^CTKUTL
        S S=$V(START) F N=2:2:ERNMB-1*2 S S=S_","_$V(START+N)
        S S=S_";"_$V(ST+212),B="" I $E(DEV,1)="D" S B=$V(ST+205)*65536+$V(ST+206),S=S_";"_B
        S RTYCT=$V(ST+211)#256 I RTYCT>127 S RTYCT=RTYCT-256
        I $V(ST+204)\2#2 S RTYCT=RTYCT+1000
        S S=S_";"_RTYCT
        S $P(S,";",6)=$V(ST+204),$P(S,";",7)=$V(ST+211)
        S ^SYS(0,"ERROR",DEV,U,+CURH,$P(CURH,",",2))=S
        Q
ERR     S ZE=$ZE,$ZT="ERR2" ZU $V(ST+346)#256:(:::::32) W !!,ZE
        I ZE["DKHER" S MPMS=$V(ST+205)*65536+$V(ST+206) I MPMS W " at block ",MPMS," on ",$C($V(ST+208)#256),$C($V(ST+209)),$C($V(ST
+210)#256+48)
        G TEST^CTK0
ERR2    I $V(ST+204)\8#2 H TIM G ERR
        H
