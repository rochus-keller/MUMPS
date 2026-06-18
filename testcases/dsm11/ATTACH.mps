ATTACH  ;2-Jul-83 ;UTILITIES ;MISC. ;Attach terminal to a job, in programmer mode ;JBH
        I '$V(2,$J)#2 W !,"Can't attach unless programmer." Q
        S JM=$V($V($V(44)+6)+1)\2
JOB     U 0 W !,"Attach to which job number ? " R JOB
        I JOB=""!(JOB="^") Q
        I JOB="?"!(JOB'?.N)!(JOB=0)!(JOB>JM) W !,"Enter the number of a currently active job (in the range 1-",JM,"." G JOB
        I $V(2,JOB)="" W " -- there's no active job with that number.",! G JOB
        S JT=$V($V(44)+8)
        S PRINIO=$V(146,JOB)#256
        I $V(JT+PRINIO)#256\2=JOB W " -- that job is already attached to device ",PRINIO,".",! G JOB
        S PRINIO=$V(146,$J)#256
        W !,"Device ",PRINIO," now attached to job ",JOB,".",!
        V 146:JOB:$V(147,JOB)*256+PRINIO
        I PRINIO#2 V JT+PRINIO-1::JOB*2*256+($V(JT+PRINIO-1)#256)
        E  V JT+PRINIO::$V(PRINIO+JT+1)*256+(JOB*2)
        V 2:JOB:$V(2,JOB)\2*2+1
        H
