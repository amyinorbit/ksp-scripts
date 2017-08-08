wait 5.
copypath("0:/peg_lib", "").
run once peg_lib.

declare parameter pe to 200.
declare parameter ap to 220.
declare parameter inc to 51.6.
declare parameter u to 0.
declare parameter kick_start is 22.
declare parameter kick_end is 60.
declare parameter kick is 17.
declare parameter burn is 300.
declare parameter hdg to -1.

set peg_meco_ap to 165.
set peg_eps to 12.
set peg_gcap to 3.5.
set peg_maxqdip to 0.9.
set fairing to false.
set s_T to burn.

peg_ascent(pe, ap, u, inc, kick_start, kick_end, kick, hdg).

