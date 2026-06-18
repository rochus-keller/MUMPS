%PSEDIT ;1-Dec-81 ;UTILITY ;SYMBOLS ;SYMBOL TABLE EDITOR ;JHM
        U 0 W !,"PROGRAM SYMBOL EDITOR"
LIB     ;
        U $I:(::::16384)
        R !,"Library to Edit > ",LIB
        U $I:(:::::16384)
        I LIB=""!(LIB="^")!($ZB#256=27) G EXIT
        I LIB="^L" D LSTLIB G LIB
        I LIB="?" D HLPLIB G LIB
        I '$D(^P(LIB)) W !,"No entries in this library"
SYM     ;
        U $I:(::::16384)
        R !,"Symbol > ",SYM
        U $I:(:::::16384)
        I SYM=""!(SYM="^") G LIB
        I SYM="^L" D LSTSYM G SYM
        I $E(SYM,1)="-" K ^P(LIB,$E(SYM,2,999)) W "- Deleted" G SYM
        I SYM="?" D HLPSYM G SYM
        S PNT=1 D SEARCH
        I BD S VAL=""
        E  S VAL=^P(LIB,SYM)
        W !
EDIT    W !,SYM," = < ",VAL R " > ",NEW
        I NEW="^"!($ZB#256=27) G SYM
        I NEW="?" D HLPEDI G EDIT
        I NEW="-" K ^P(LIB,SYM) W " - Deleted" G SYM
        I NEW'="" S VAL=NEW G EDIT
        S ^P(LIB,SYM)=VAL
        G SYM
EXIT    Q
SEARCH  S %X=0,ISYM=SYM
        I $D(^P(LIB,ISYM)) S %X=%X+1,REC(%X)=ISYM G DONE
SNXT    S ISYM=$N(^P(LIB,ISYM)) G DONE:ISYM<0
        I ($E(ISYM,1,$L(SYM))'=SYM)!(%X>23) G DONE
        S %X=%X+1,REC(%X)=ISYM G SNXT
DONE    I %X<1 D GOTNO S BD=1 G QUIT
        I %X=1 W:PNT $P(REC(%X),SYM,2,80) D SET S BD=0 G QUIT
PICK    W !!!,"Which one:",! S PICK=1
        F %I=1:1:%X W !,%I,?5,REC(%I)
CHC     U 0 R !!,"Enter a NUMBER > ",%I
        I '$T!(%I="") S BD=1 G QUIT
        I $ZB#256=27 S %I="^"_%I
        I %I="^H" W !,"NO HELP" G PICK
        I %I'?.N D LIBDSEL G CHC
        I '$D(REC(%I)) D LIBDSEL G CHC
        S %X=%I W "  ",REC(%X) D SET S BD=0
QUIT    K %I,%X,REC,ISYM,COL,LIN,N,CSH,PNT,PICK Q
SET     S SYM=REC(%X) Q
LIBDNAM W !,"Control characters are not allowed in symbol names: "_SYM,*7 Q
LIBDESC W !,""""_$E(SYM,2,100)_""" <ESC> is not a valid special function",*7 Q
GOTNO   W !,"You don't have a symbol named """_SYM_"""",*7 Q
LIBDSEL W !!,"Incorrect selection",*7 Q
LSTSYM  S COL=1 W !!,"SYMBOL DIRECTORY of ",LIB,!! S ISYM=-1
HNXT    S ISYM=$N(^P(LIB,ISYM)) I ISYM<0 W:$X ! W ! U 0 Q
        W ?COL,ISYM S COL=COL+25 I COL>50 S COL=1 W !
        G HNXT
LSTLIB  S COL=1 W !!,"LIBRARY Directory",!! S LIB=-1
NXT     S LIB=$N(^P(LIB)) I LIB<0 W:$X ! W ! U 0 Q
        W ?COL,LIB S COL=COL+25 I COL>50 S COL=1 W !
        G NXT
HLPSYM  S TXT="HSYM" G HELP
HLPEDI  S TXT="HEDI" G HELP
HLPLIB  S TXT="HLIB"
HELP    S C=$P($T(@TXT),";;",2) F I=1:1:C W !,$P($T(@TXT+I),";;",2)
        Q
HLIB    ;;4
        ;;Enter the name of the symbol LIBRARY that contains the symbol
        ;;you wish to enter, delete, or edit.  Enter the entire name
        ;;Type ^L to get a complete list of the current library.  Enter
        ;;a new library name to create a new library
HSYM    ;;5
        ;;Enter the name of the symbol you wish to create, edit or delete.
        ;;You may enter all or part of an existing symbol in order to edit
        ;;or delete it.
        ;;
        ;;To delete a symbol enter the symbol name preceded by a "-"
HEDI    ;;3
        ;;Enter "-" to delete the current symbol.
        ;;Enter a new symbol value to replace the old one.
        ;;Enter a <CR> to leave the symbol unchanged.
