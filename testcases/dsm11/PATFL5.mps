PATFL5  ;YZH;23-JUN-80;EDITOR (REPLACE COMMAND) AND HELP TEXT FOR FILE PATCHES OPTION
        W !,*7,"This subroutine should be run using the autopatch utility ^AUPAT.",!,*7 Q
REDI    S GLVAL=^SYS(0,"PATCH",PATNO,PTR) G:'PTR HD
RP1     S DEF=$P(GLVAL,"/",1) W !,?7,"Module name ? <",DEF R "> ",MODUL Q:MODUL="^"
        S:MODUL="" MODUL=DEF I MODUL["?" W !!,?7,"Enter a valid system module name",! D DEF G RP1
        S TAB=$P($T(TAB),";;",2) F I=1:1 S MODNM=$P(TAB,"/",I) Q:MODNM=""  I MODUL=MODNM G RP2
        D IV G RP1
RP2     S DEF=$P(GLVAL,"/",2) W !,?7,"Address offset ? <",DEF R "> ",ADOFF G:ADOFF="^" RP1
        S:ADOFF="" ADOFF=DEF I ADOFF["?" D HLP5^PATFL5 D DEF G RP2
        I ADOFF'?.N!(ADOFF[8)!(ADOFF[9)!(ADOFF#2) D IV G RP2
RP3     S DEF=$P(GLVAL,"/",3) W !,?7,"Old contents ? <",DEF R "> ",OLDCO G:OLDCO="^" RP2
        S:OLDCO="" OLDCO=DEF I OLDCO["?" D HLP6^PATFL5 D DEF G RP3
        I OLDCO'?.N!(OLDCO[8)!(OLDCO[9)&(OLDCO'?1"X"."X") D IV G RP3
RP4     K DIR S DEF=$P(GLVAL,"/",4) W !,?7,"New contents ? <",DEF R "> ",NEWCO G:NEWCO="^" RP3
        S:NEWCO="" NEWCO=DEF I NEWCO["?" D HLP7^PATFL5 D DEF G RP4
        I NEWCO["+" S ANS=NEWCO D MDBAS^PATFL1 G:$D(DIR) RP4 G SET
        I NEWCO'?.N!(NEWCO[8)!(NEWCO[9) D IV G RP4
SET     S ^SYS(0,"PATCH",PATNO,PTR)=MODUL_"/"_ADOFF_"/"_OLDCO_"/"_NEWCO Q
HD      R !,?7,"R ",OLDSG Q:OLDSG=""  I OLDSG="?" W "   Enter the string to be replaced",! G HD
        I GLVAL'[OLDSG W "   string not found" Q
        R "  W ",NEWSG I ($L(GLVAL)-$L(OLDSG)+$L(NEWSG))>255 W "   string too long" Q
        S ^SYS(0,"PATCH",PATNO,PTR)=$P(GLVAL,OLDSG,1)_NEWSG_$E(GLVAL,$F(GLVAL,OLDSG),255) Q
HLP1    W !!!,"Enter the number of the patch to be stored in ^SYS(0,""PATCH"") global"
        W !,"This number will be used for any future reference with the patch",! Q
HLP2    W !!!,"Enter patch date like this:    12-MAR-80"
        W !,"Or type <CR> to enter today's date",!
        Q
HLP3    W !!!,"Enter a name for the patch"
        W !,?3,"Or a brief description of the patch functions",! Q
HLP5    W !!!,?7,"Enter the offset (octal) from the module base address",!,?7,"for each patch location",! Q
HLP6    W !!!,?7,"Enter the old contents (octal) at the specified",!,?7,"patch location"
        W !,?7,"Or any number of ""X""'s if old contents unknown:  e.g.  XXXX",! Q
HLP7    W !!!,?7,"Enter the new contents to be written to the specified patch"
        W !,?7,"location in the following format:"
        W !,?7,"an octal nuumber:    13447"
        W !,?7,"Module name + Offset:    PATCH+136",! Q
HLP8    W !!,?5,"Enter the number of the patch you want to edit"
        W !,?5,"This patch must be already stored in ^SYS(0,""PATCH"") global",! Q
HLP9    W !!,?5,"Available commands:"
        W !,?5,"L  followed by a line number to display contents of",!,?8,"specified global line:  e.g.  L 8"
        W !,?5,"S  step to display contents of next global line"
        W !,?5,"R  replace a string of current global line",!,?5,"D  delete current global line"
        W !,?5,"I  insert a line after current global line",! Q
DEF     W ?7,"Enter <CR> will give default",! Q
IV      W !!,?7,"Incorrect response, enter ""?"" for help",! Q
TAB     ;;VECTOR/SYSTAB/EXEC/MUMPS/CSPOOL/PATCH/INTERP/SUBRS/EVAL/SYMBOL/GLOBAL/USPOOL/ALLOC/ZCALL/BDBTAB/KEXEC/DISK/EMT/KIOD/KSPOOL/DSMXDT/MTD/EBCDIC/JRNL/SDP/MODEM/DMC/JOBCOM/DDP/USRDRV/DDBTAB/CONFIG/BOOTDK/TU58/RX02/BISYNC
