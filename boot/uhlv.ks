wait 5.
copypath("0:/peg_lib", "").
run once peg_lib.

declare parameter pe to 130.
declare parameter ap to 200.
declare parameter inc to -28.7.
declare parameter u to 0.
declare parameter kick_start is 12.
declare parameter kick_end is 50.
declare parameter kick is 22.
declare parameter burn is 200.
declare parameter hdg to 89.

set peg_launchcap to 0.9.

set peg_eps to 8.
set peg_meco_ap to 110.
set peg_maxqdip to 0.75.
set peg_gcap to 2.1.
set fairing to true.
set s_T to burn.

peg_ascent(pe, ap, u, inc, kick_start, kick_end, kick, hdg).

