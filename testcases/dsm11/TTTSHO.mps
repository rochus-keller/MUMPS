TTTSHO  ;DISPLAY TIED TERMINAL TABLE
        S TTT=$V(44)+318,T=0
        F I=0:4:36 S II=I\4,T(II)=$V(TTT+I),T(II+10)=$V(TTT+I+2) I T(II)'=0 S T=T+1
SHO     W !!,"******* Tied Terminal Table *******",!!
        I 'T W !,"** Tied terminal table is empty **" Q
        W !,"ROUTINE #   VOLUME SET  UCI #   PARTITION SIZE   ROUTINE NAME"
        W !,"              NUMBER           (1KB increments)"
        W !,"----------  ----------  -----  ----------------  ------------"
        F I=0:1:6 W:T(I)'=0 !?3,$J(I+1,4),?16,"S",T(I)\256\32,?25,T(I)\256#32,?37,T(I)#256,?53,$C(T(I+10)#128),$C(T(I+10)\256)
        W ! K  Q
