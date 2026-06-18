DDR     ;JHM;13-JUN-80;OCTAL DUMP OF A DDB
        S ST=$V(44),MAXTTY=$V(ST+462)#256
STT     S QUES="IQ",DEF="" X ^%Q("EN") G:ANS="^"!(ANS="") EXIT
        I ANS'?1N.N D IQH G STT
        S DEV=ANS S:'DEV DEV=$I
        I $V($V(ST+8)+DEV)#256=255 W " - device not configured,  type '?' for help." G STT
        I DEV<20 S ADDR=$V(ST+10)+((DEV-1)*$V(ST+68)),L=$V(ST+68) D SNAP G STT
        I DEV>46,DEV<51 S L=$V(ST+298),ADDR=DEV-47*L+$V(ST+22) D SNAP G STT
        I DEV>58,DEV<64 S L=$V(ST+232),ADDR=DEV-59*L+$V(ST+408) D SNAP G STT
        I DEV>63,DEV'>MAXTTY S ADDR=$V(ST+20)+((DEV-64)*$V(ST+68)),L=$V(ST+68) D SNAP G STT
        I DEV>223,DEV<256 S L=$V(ST+300),ADDR=$V(ST+358)+(DEV-224*L) D SNAP G STT
IV      W !?5,"Incorrect response, type '?' for help." G STT
ERR     U 0 I $ZE["INRPT" W !,"***Interrupt***",!
        E  W !,$ZE
EXIT    U 0 I $D(%IOD),%IOD'=$I C %IOD
        K %T,I2,L,DEV,ADDR,I1,%DO,ST,%IOD Q
SNAP    W !! F I=1:1:L\2 D
        .I '$X W "(" S %DO=ADDR D ^%DO W %DO,")"
        .S %DO=$V(ADDR),ADDR=ADDR+2 D ^%DO W ?$X+9\10*10,$J(%DO,8)
        .I $X>70 W !
        W ! Q
IQ      W !,"Show DDB for device ?" Q
IQH     W !?5,"Enter a valid terminal or JOBCOM device number."
        W !?5,"Enter '0' to see your terminal's DDB."
        W !?5,"Terminals can be 1-19, 64-",MAXTTY,", JOBCOM is devices 224-255."
        W !?5,"Enter <CR> or ^ to exit.",! Q
