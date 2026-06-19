JRNLSHOW        ;
START   S MSG=1 W !!,"Currently defined Journal spaces:",!! G JS2
NOMSG   S MSG=0
JS2     S IX=0,ND=0
NXSP    S IX=$N(^SYS(0,"JOURNAL SPACE",IX)) G NOMOR:IX'?.N S ND=ND+1,ND(ND)=IX
        D SHOW1:MSG G NXSP
NOMOR   W:MSG&'ND " No Journal spaces currently defined",!!
        K IX,MSG Q
SHOW1   W "Space #",IX," on ",^SYS(0,"JOURNAL SPACE",IX,"DISK"),?17,"Name = ",^("NAME"),!
        W ?6,"Start DSM Blk#  = ",^("START"),!
        W ?6,"End DSM Blk#    = ",^("END"),!
        S NEXTBLK=$S(^("NEXT")?.N:^("NEXT"),^("NEXT")="CURRENT":$V($V(44)+296)#256*65536+$V($V(44)+294),1:"* "_^("NEXT")_" *")
        W ?6,"Next avail. blk = ",NEXTBLK,!
        W ?6,"Blocks Used     = ",$S(NEXTBLK?.N:NEXTBLK-^("START")-(NEXTBLK-^("START")\400),NEXTBLK="* EMPTY *":0,1:^("END")-^("START")+1\400*399),!
        W ?6,"Blks Remaining  = ",$S(NEXTBLK?.N:^("END")-NEXTBLK+1-(^("END")-NEXTBLK+400\400),NEXTBLK="* EMPTY *":^("END")-^("START")+1\400*399,1:0),!!
        K NEXTBLK
        Q
CUR     ;
        Q:'$D(^SYS(0,"JOURNAL SPACE","CURRENT"))
        W ! S IX=^("CURRENT") D SHOW1 K IX Q
