STUCSR  ;CHECK DEVICE CSR'S (CALLED BY STARTUP ROUTINE) ;6-NOV-80
        K NOCSR
        I ^SYS(ID,"MEMORY SIZE","K BYTES")>($V($V(44)+418)\16) D MEMSIZ
        S CONT="",NO=""
CONT    S CONT=$O(^SYS(ID,"CONTROLLER",CONT)) G:CONT="" DONE
NO      S NO=$O(^SYS(ID,"CONTROLLER",CONT,NO)) G:NO="" CONT
        S %OD=^(NO,"CSR") D %OD I $V(%OD)="" D NODEV
        G NO
DONE    W:$D(NOCSR) !!?5,"Startup aborted....",!! K SINGLE,DH11,DZ11,DDPNO,%OD,I Q
MEMSIZ  W !?5,"The memory size required for configuration '",ID,"' is ",^SYS(ID,"MEMORY SIZE","K BYTES"),"K bytes,"
        W !?5,"but you only have ",$V($V(44)+418)\16,"K bytes memory!",! S NOCSR="" Q
NODEV   W !?5,"Controller ",CONT," # ",NO," does not exist" S NOCSR="" Q
%OD     I %OD'?1N.N!($L(%OD)>27)!(%OD[8)!(%OD[9) S %OD="B" Q
        S %B=0 F %I=1:1:$L(%OD) S %B=%B*8+$E(%OD,%I)
        S %OD=%B K %I,%B Q
Z       P STUCSR ZS STUCSR Q
