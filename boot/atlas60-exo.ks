wait 5.
copypath("0:/peg_lib", "").
run once peg_lib.

declare parameter pe to 100.
declare parameter ap to 130.
declare parameter inc to -28.7.
declare parameter u to 180.
declare parameter kick_start is 25.
declare parameter kick_end is 60.
declare parameter kick is 19.5.
declare parameter burn is 300.
declare parameter hdg to 90.

set peg_boosters to 0.
set peg_meco_ap to 110.
set peg_eps to 12.
set peg_gcap to 4.0.
set peg_maxqdip to 0.95.
set fairing to true.
set s_T to burn.

peg_ascent(pe, ap, u, inc, kick_start, kick_end, kick, hdg).

