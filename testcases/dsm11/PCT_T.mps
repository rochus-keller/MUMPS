%T      ;FDN; CONVERT $H TIME TO HH:MM AND HH:MM AM/PM
ST      S %TM=$P($H,",",2)
CVT     D %CTS^%H I '$D(%NP) W %TIM1 K %TIM,%TIM1
        K %TM,%NP Q
INT     S %NP="" G ST
20      S %TM=%M G CVT
