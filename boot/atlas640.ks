wait 5.
copypath("0:/peg_lib", "").
run once peg_lib.

declare parameter pe to 150.
declare parameter ap to 1000.
declare parameter inc to 45.
declare parameter u to 45.
declare parameter kick_start is 10.
declare parameter kick_end is 40.
declare parameter kick is 18.
declare parameter burn is 300.
declare parameter hdg to -1.

set peg_boosters to 1.
set peg_meco_ap to 160.
set peg_eps to 12.
set peg_gcap to 2.1.
set peg_maxqdip to 0.9.
set fairing to false.
set s_T to burn.

peg_ascent(pe, ap, u, inc, kick_start, kick_end, kick, hdg).

