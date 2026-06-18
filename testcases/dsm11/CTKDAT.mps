CTKDAT  Q  ;DB;DEC 80;DATE TIME ROUTINE FOR CARETAKER
H       S %DT=+$H,%H=%DT>21914+%DT
        S %LY=%H\1461,%R=%H#1461,%Y=%LY*4+1841+(%R\365),%D=%R#365,%M=1
        I %R=1460,%LY'=14 S %D=365,%Y=%Y-1
        F %I=31,(%R>1154)&(%LY'=14)+28,31,30,31,30,31,31,30,31,30 Q:%I'<%D  S %M=%M+1,%D=%D-%I
        I %D=0 S %Y=%Y-1,%M=12,%D=31
        S %DAT=%D_"-"_$P("Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec"," ",%M)_"-"_$E(%Y,3,4)
        S %TM=$P($H,",",2)
        S %M=%TM#3600\60,%S=%TM#60,%TIM=%TM\3600_":"_(%M\10)_(%M#10)
        S %TIM1=%TIM,%A=$S(%TM<43200:"AM",1:"PM") I $P(%TIM,":",1)>12 S %TIM1=$P(%TIM,":",1)-12_":"_$P(%TIM,":",2,99)
        S %TIM1=%TIM1_" "_%A
        W %DAT,"  ",%TIM1
        K %A,%D,%DAT,%DT,%H,%I,%LY,%M,%M,%R,%S,%TIM,%TIM1,%TM,%Y Q
ERR     S ZE=$ZE,$ZT="ERR2" ZU ZDEV:(:::::32) W !!,ZE
        I ZE["DKHER" S MPMS=$V(ST+205)*65536+$V(ST+206) I MPMS W " at block ",MPMS,!
        G TEST^CTK0
ERR2    I $V(ST+204)\8#2 H TIM G ERR
        H
