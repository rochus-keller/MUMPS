%D      ;FDN; CONVERT $H DATE TO DD-MMM-YY AND MM/DD/YY
05      ;
ST      S %DT=+$H
CVT     D %CDS^%H I '$D(%NP) W %DAT1 K %DAT,%DAT1
        K %DT,%NP Q
INT     S %NP="" G ST
10      S %DT=%H G CVT
