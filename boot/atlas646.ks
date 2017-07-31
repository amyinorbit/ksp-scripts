wait 5.
copypath("0:/peg_lib", "").
run once peg_lib.

declare parameter pe to 120.
declare parameter ap to 200.
declare parameter inc to -28.8.
declare parameter u to 0.
declare parameter kick_start is 3.
declare parameter kick_end is 35.
declare parameter kick is 29.
declare parameter burn is 300.
declare parameter hdg to 90.

set peg_boosters to 3.
set peg_eps to 12.
set peg_meco_ap to 110.
set peg_gcap to 3.0.
set peg_maxqdip to 0.8.
set fairing to true.
set s_T to burn.

peg_ascent(pe, ap, u, inc, kick_start, kick_end, kick, hdg).

