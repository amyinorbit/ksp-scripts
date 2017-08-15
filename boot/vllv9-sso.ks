wait 5.
copypath("0:/peg_lib", "").
run once peg_lib.

declare parameter pe to 180.
declare parameter ap to 500.
declare parameter inc to 92.
declare parameter u to 0.
declare parameter kick_start is 15.
declare parameter kick_end is 60.
declare parameter kick is 30.
declare parameter burn is 200.
declare parameter hdg to -1.

set peg_launchcap to 0.92.

set peg_eps to 8.
set peg_meco_ap to 140.
set peg_maxqdip to 0.9.
set peg_gcap to 4.5.
set fairing to true.
set s_T to burn.

peg_ascent(pe, ap, u, inc, kick_start, kick_end, kick, hdg).
