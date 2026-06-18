AUPAT1  ;YZH;23-JUN-80;FILE PATCHES OPTION SELECTOR
        W !,*7,"This subroutine should be run using the autopatch utility ^AUPAT.",!,*7 Q
START   W !!!,"Maintain patches",!
        W !," 1. CREATE",!," 2. DELETE",!," 3. EDIT",!," 4. LIST"
        R !!,"Enter one of the above options > ",OPT I OPT=""!(OPT="^") K OPT Q
        I OPT["?" D HLP G START
        I OPT?1N&("1234"[OPT) D @("START^PATFL"_OPT) G START
        S LEN=$L(OPT) F I=1:1:4 S TAB=$P($T(TAB+I-1),";;",2) I $E(TAB,1,LEN)=OPT G SET
        W !!,"   Incorrect response, enter ""?"" for help" G START
SET     W $E(TAB,LEN+1,99),! D @("START^PATFL"_I) G START
HLP     W !!!,"To create new patches in ^SYS(0,""PATCH"") global"
        W !,"Enter ""1"" or ""C"""
        W !!,"To delete certain patches from ^SYS(0,""PATCH"") global"
        W !,"Enter ""2"" or ""D"""
        W !!,"To correct or modify patch data stored in ^SYS(0,""PATCH"") global"
        W !,"Enter ""3"" or ""E"""
        W !!,"To print contents of certain patches stored in ^SYS(0,""PATCH"") global"
        W !,"Enter ""4"" or ""L""",! Q
HLP1    W !!!,"If you want to create or modify an entry in the ^SYS(0,""PATCH"") global,"
        W !,"Enter the number 1."
        W !!,"If you want to install patches stored in ^SYS(0,""PATCH"") global"
        W !,"to memory or disk or both,",!,"Enter the number 2."
        W !!,"If you want to reverse already applied patches stored in "
        W !,"^SYS(0,""PATCH"") global from memory or disk or both,",!,"Enter the number 3."
        W !!,"If you want to check whether the patches stored in ^SYS(0,""PATCH"")"
        W !,"global have been applied to memory or disk,",!,"Enter the number 4.",! Q
HLP2    W !
HLP3    W !,"Enter   NUM   to include the patch with number NUM"
        W !,?3,"or   -NUM  to exclude the patch with number NUM"
        W !,?3,"or   '*'   to include all the patches in ^SYS global",! Q
TAB     ;;CREATE
        ;;DELETE
        ;;EDIT
        ;;LIST
