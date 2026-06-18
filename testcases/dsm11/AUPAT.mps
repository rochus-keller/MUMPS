AUPAT   ;YZH;10-JUN-81;ENTRY ROUTINE TO AUTOPATCHER
        W !,"D ^PATCH to run the system patching utilities",! Q
APPLY   S OPT=2 D INIT Q:ERR  D MDB Q
REMOVE  S OPT=3 D INIT Q:ERR  D MDB Q
VERIFY  S OPT=4,MDB="B" D INIT Q:ERR  D START Q
MDB     W !!,$S(OPT=2:"Apply patches to",1:"Remove patches from")
        R " memory (M) or disk (D) or both (B) ? <M> ",MDB G:MDB="^" DONE
        S:MDB="" MDB="M" I MDB["?" W !!?5,"Enter 'M' or 'D' or 'B', Please!" G MDB
        I MDB'?1U!("MDB"'[MDB) D IV G MDB
        D START G DONE
MEMPAT  S OPT=2,MDB="M",HTU="" D INIT G ST
START   K %ALL,%MI W !!,$S(OPT=2:"Apply",OPT=3:"Remove",1:"Verify") R " patch number ? >",%X I %X="^"!(%X="") Q
        I "?"[%X D HLP2 G START
CK      I %X="*" S %L1(%X)="" G RP
        I $E(%X,1)="-" S %MI="",%X=$E(%X,2,$L(%X))
        I %X'?1N.ANP D IV G:$D(%L1)!$D(%L2) RP G START
        I '$D(^SYS(0,"PATCH",%X)) W !!?5,"Patch #",%X," not defined",! G:$D(%L1)!$D(%L2) RP G START
        S:'$D(%MI) %L1(%X)="" S:$D(%MI) %L2(%X)=""
RP      W !,$S(OPT=2:"Apply",OPT=3:"Remove",1:"Verify") R " patch number ? > ",%X Q:%X="^"
        I %X="" S:'$D(%L1) %L1("*")="" G ST
        I %X["?" W ! D HLP3^AUPAT1 G RP
        K %MI G CK
ST      I '$D(^SYS(0,"PATCH")) W !!,"^SYS(0,""PATCH"") not defined",! Q
        W:OPT=2 !!,"** Patching DSM **",! W:OPT=3 !!,"** Remove DSM patches **",!
        W:OPT=4 !!!,?10,"Patch #",?22,"Applied to",?37,"Applied to",!,?24,"memory",?40,"disk",!
        B 0 S ST=$V(44),PATNO=-1,PATCT1=0,PATCT2=0 G NEXT^AUPAT0
DONE    K DISK,MEM B 1 C 63 Q
INIT    S ERR=0 C 63 O 63::1 E  W !,"View device 63 unavailable",! S ERR=1 Q
        U 63:(::"Z"),0 V 0:"S0" S ANSTRT=$V(497,0)*65536+$V(498,0) U 63:(::"C"),0
        S ST=$V(44) V 2:"S0" S DST=$V(44,0),TAB=DST+92
        K DISK,MEM
        F I=2:1:$L($T(COM),";;") S MODUL=$P($T(COM),";;",I) D
        .S MEM(MODUL)=$V(TAB)_","_$V(TAB)_",-2"
        .S DISK(MODUL)=$V(TAB,0)_","_$V(TAB,0)
        .S TAB=TAB+2
        F I=2:1:$L($T(USE),";;") S MODUL=$P($T(USE),";;",I) D
        .S MEM(MODUL)=$V(TAB)_","_$V(TAB)_",-2"
        .S DISK(MODUL)=$V(TAB,0)_","_($V(DST+26,0)*64+$V(TAB,0)-8192)
        .S TAB=TAB+2
        F I=2:1:$L($T(KERNEL),";;") S MODUL=$P($T(KERNEL),";;",I) D
        .S MEM(MODUL)=$V(TAB)_","_$V(TAB)_",-1"
        .S DISK(MODUL)=$V(TAB,0)_","_($V(DST+28,0)*64+$V(TAB,0)-8192)
        .S TAB=TAB+2
        S MBASE=0
        F I=2:1:$L($T(MKERNL),";;") S MODUL=$P($T(MKERNL),";;",I) D
        .S MEM(MODUL)="32768,0,"_$V(TAB)
        .S DISK(MODUL)="32768,"_($V(TAB,0)*64+MBASE),MBASE=$P(DISK(MODUL),",",2)
        .S TAB=TAB+2
        F I=2:1:$L($T(ONDISK),";;") S MODUL=$P($T(ONDISK),";;",I) D
        .S MEM(MODUL)=0
        .S DISK(MODUL)="32768,"_($V(TAB,0)-32768+MBASE)
        .S TAB=TAB+2
        F I=2:1:$L($T(DKONLY),";;") S MODUL=$P($T(DKONLY),";;",I) D
        .S MEM(MODUL)="0,0,0"
        Q
COM     ;;VECTOR;;SYSTAB;;EXEC;;MUMPS;;PATCH
USE     ;;INTERP;;SUBRS;;EVAL;;SYMBOL;;GLOBAL;;ALLOC;;ZCALL
KERNEL  ;;KEXEC;;DISK;;EMT;;JRNL;;EBCDIC;;DSMXDT;;DDBTAB;;CONFIG
MKERNL  ;;KIOD;;MTD;;KSPOOL;;SDP;;DMC;;JOBCOM;;DDP;;USRDRV;;SYSEND
ONDISK  ;;BOOTDK;;TU58;;RX02;;BISYNC
DKONLY  ;;DDBTAB;;CONFIG;;USRDRV;;SYSEND
IV      W !!,?3,"Incorrect response, enter ""?"" for help",! Q
HLP2    W !
        W !,"Enter   NUM   to include the patch with number NUM"
        W !,?3,"or   -NUM  to exclude the patch with number NUM"
        W !,?3,"or   '*'   to include all the patches in ^SYS patch global",! Q
SHOMAP  S MODUL=""
        W !!?16,"Memory",?47,"Disk"
        W !?12,"Base",?22,"View Mode",?42,"Base",?56,"Phys",!
S2      S MODUL=$O(MEM(MODUL)) I MODUL="" W !! Q
        W !,MODUL S %DO=+MEM(MODUL) D ^%DO W ?10,$J(%DO,6),?22,$P(MEM(MODUL),",",2,3)
        G S2:'$D(DISK(MODUL))
        S %DO=+DISK(MODUL) D ^%DO W ?40,$J(%DO,6)
        S %DO=$P(DISK(MODUL),",",2) D ^%DO W ?54,$J(%DO,6)
        G S2
Z       P AUPAT ZS AUPAT Q
