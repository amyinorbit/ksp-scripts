wait 5.
copypath("0:/peg_lib", "").
run once peg_lib.

declare parameter pe to 130.
declare parameter ap to 200.
declare parameter inc to -45.
declare parameter u to 0.
declare parameter kick_start is 25.
declare parameter kick_end is 55.
declare parameter kick is 14.
declare parameter burn is 200.
declare parameter hdg to 127.

set peg_eps to 8.
set peg_meco_ap to 115.
set peg_maxqdip to 0.8.
set peg_gcap to 2.05.
set fairing to true.
set s_T to burn.

peg_ascent(pe, ap, u, inc, kick_start, kick_end, kick, hdg).

