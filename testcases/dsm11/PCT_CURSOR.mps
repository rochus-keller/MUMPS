%CURSOR ;TLW;%CURSOR,UTL PKG,DSM-11 ;25SEPT79;SET DEVICE CURSOR CTRL ARRAY
        K %CUR
        U $I:(::::1) W *27,*90 H 1 R *%T:0,*%T:0,*%T:0 U $I:(:::::1)
        U 0 I '%T S %T=7 G LOOP
        S %T=$F("ABECHJKLZ",$C(%T)) I '%T S %T=7 G LOOP
        S %T=$E("223344556",%T-1) S:%T="" %T=7
LOOP    S %T1=%T F %I=0:1 S %X=$T(TYPE+%I) Q:%X=""  S:$P(%X,"^",%T)?1N %T=$P(%X,"^",%T) S %CUR($P(%X," ",1))=$P(%X,"^",%T) S %T=%T1
        K %I,%X,%T,%T1 Q
TYPE    ^VT50^VT55^VT50H^VT52^VT100^DEFAULT
RIGHT   ^*13^2^2^2^2^?1
HOME    ^*27,*72^2^2^2^2^!
TAB     ^*9^2^2^2^2^?$X#8
DIRECT  ^7^*27,*89,*(%L+31),*(%C+31)^7^3^3^!
EEL     ^*27,*75^2^2^2^2^!
EES     ^*27,*74^2^2^2^2^!
BELL    ^*7^2^2^2^2^2
ID      ^*27,*90^2^2^2^2^
LF      ^*10^2^2^2^2^2
DOWN    ^*27,*26^2^2^2^2^*10
RLF     ^*27,*73^2^2^2^2^!
UP      ^*27,*65^2^2^2^2^!
SPACE   ^*32^2^2^2^2^ ^
CRLF    ^*27,*67^2^2^2^2^!
LEFT    ^*8^2^2^2^2^
HON     ^*27,*91^2^2^2^^
HOFF    ^*27,*92^2^2^2^^
AKON    ^^*27,*61^^3^3^
AKOFF   ^^*27,*62^^3^3^
GMON    ^^*27,*70^^^3^
GOFF    ^^*27,*71^^^3^
Y       ^12^24^12^24^24^12
X       ^78^80^78^80^80^78
