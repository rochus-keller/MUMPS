MBP     ;RLW; MODIFY BASIC SYSTEM PARAMETERS
        D ID^SYSROU Q:ID="^"  S SOFT=0,ST=$V(44),SGN=0,EXTH=0 D SYSGEN D:'%A ^MDAT Q
SYSGEN  K (ID,ST,SOFT,EXTH,SGN,DMB,MEMTOT,MEMUSE,PARMIN,KERSIZ,CCEND,EDIT,AUTO)
        W ! W:SGN "PART 11:",?10,"DATABASE PARAMETERS",!,"--------",!
        S DEF=500 I $D(^SYS(ID,"MISCELLANEOUS","WRITE DEMON TIMER")) S DEF=^("WRITE DEMON TIMER")
        S ANS=DEF
        I DMB'="D" V ST+354::ANS\100
        E  S ^SYS(ID,"MISCELLANEOUS","WRITE DEMON TIMER")=DEF
        S MDM=0 I ^SYS(ID,"OPTIONS","MODEM")="N" G DZSET
        F C="DZ11","DZV11" F I=0:1:^SYS(ID,"CONTROLLER",C)-1 I $D(^SYS(ID,"CONTROLLER",C,I,"MODEM CONTROL")),^("MODEM CONTROL")="Y"
S MDM=200
DZSET   I DMB'="M" S ^SYS(ID,"MISCELLANEOUS","DZ11 TIMER")=MDM
        I DMB'="D" V ST+388::$V(ST+389)*256+(MDM\100)
WRTCHK  S DEF="N",QUES="CHK" X:EXTH ^%Q("EXTH")
        I SOFT S ANS="N",FEAT="WRITE CHECK after WRITE on disks" D FEAT^MBP1 G SETCHK
        I $D(^SYS(ID,"DISK","WRITE CHECK")) S DEF=^("WRITE CHECK")
        X ^%Q("SGASKYN") G:%A RETURN
SETCHK  I DMB'="M" S ^SYS(ID,"DISK","WRITE CHECK")=ANS
        I DMB'="D" V ST+70::ANS="Y"*256+($V(ST+70)#256)
GBLDEF  S QUES="DEFDSK" X:EXTH ^%Q("EXTH")
        W !,"System default global characteristics are:",!!
        I SOFT S B8DEF="Y",JLDEF="N",CSDEF="N"
        E  I $D(^SYS(ID,"MISCELLANEOUS","GLOBAL DEFAULT")) D
        .S GLDEF=^("GLOBAL DEFAULT"),B8DEF=$P($P(GLDEF,";",1),",",2),JLDEF=$P($P(GLDEF,";",2),",",2),CSDEF=$E($P(GLDEF,";",3),1)
        E  S GLDEF=$V(ST+293),B8DEF=$S(GLDEF\2#2:"Y",1:"N"),JLDEF=$S(GLDEF\4#2:"Y",1:"N"),CSDEF=$S(GLDEF#2:"S",1:"N")
        W ?6,"8 Bit Subscripts:",?26,$S(B8DEF="Y":"Yes",1:"No"),!?6,"Journaling:",?26,$S(JLDEF="Y":"Yes",1:"No")
        W !?6,"Collating sequence:",?26,$S(CSDEF="N":"Numeric",1:"String"),!
        I SOFT G SETDEF
CHNG    S QUES="DEFDSK" X ^%Q("SGASKN") G:%A WRTCHK
        I $E(ANS)="N" G:'$D(^SYS(ID,"MISCELLANEOUS","GLOBAL DEFAULT")) SETDEF G DONE
BIT     S QUES="BIT8",DEF=B8DEF X ^%Q("SGASKYN") G:%A CHNG S B8DEF=ANS
JRNL    S QUES="JRND",DEF=JLDEF X ^%Q("SGASKYN") G:%A BIT S JLDEF=ANS
COL     S QUES="COLD",DEF=CSDEF X ^%Q("SGEN") G:%A JRNL I "NS"'[$E(ANS) D IV G COL
        S CSDEF=ANS
SETDEF  I DMB'="D" V ST+292::(B8DEF="Y")*2+((JLDEF="Y")*4)+(CSDEF="S")*256+($V(ST+292)#256)
        I DMB'="M" S ^SYS(ID,"MISCELLANEOUS","GLOBAL DEFAULT")="8 BIT"_","_B8DEF_";"_"JOURNAL"_","_JLDEF_";"_$S(CSDEF="S":"STRING",1:"NUMERIC")
DONE    D START^MBP1 I %A G:'SOFT GBLDEF
RETURN  Q
IV      W !,"   Incorrect response - enter '?' for more information",! Q
BIT8H   ;;0
JRNDH   ;;0
COLDH   ;;0
DEFDSKH ;;0
CHKH    ;;0
HELP    S TAG=QUES_"H" D TEXT^MBPH Q
CHK     ;;1;;11.1;;1
        ;;Enable WRITE CHECK after every DISK WRITE
DEFDSK  ;;1;;11.2;;1
        ;;Change the DEFAULT GLOBAL CHARACTERISTICS
BIT8    ;;1;;11.3;;1
        ;;Global format will support 8 Bit subscripts
JRND    ;;1;;11.4;;1
        ;;Globals will be JOURNALED
COLD    ;;1;;11.5;;1
        ;;String or Numeric collating sequence [S or N]
