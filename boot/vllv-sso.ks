wait 5.
copypath("0:/peg_lib", "").
copypath("0:/exec_lib", "").
run once peg_lib.
run once exec_lib.

declare parameter pe to 160.
declare parameter ap to 500.
declare parameter inc to 92.
declare parameter u to 0.
declare parameter kick_start is 12.
declare parameter kick_end is 50.
declare parameter kick is 28.
declare parameter burn is 200.
declare parameter hdg to -1.

set peg_launchcap to 0.92.

set peg_eps to 8.
set peg_meco_ap to 140.
set peg_maxqdip to 0.9.
//set peg_gcap to 2.2.
set fairing to false.
set s_T to burn.

peg_ascent(pe, ap, u, inc, kick_start, kick_end, kick, hdg).
