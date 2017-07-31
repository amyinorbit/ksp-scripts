wait 5.
copypath("0:/peg_lib", "").
copypath("0:/exec_lib", "").
run once peg_lib.
run once exec_lib.

declare parameter pe to 150.
declare parameter ap to 250.
declare parameter inc to 2.
declare parameter u to 0.
declare parameter kick_start is 20.
declare parameter kick_end is 52.
declare parameter kick is 17.
declare parameter burn is 200.
declare parameter hdg to 90.

set peg_launchcap to 1.0.

set peg_eps to 8.
set peg_meco_ap to 120.
set peg_maxqdip to 0.8.
set peg_gcap to 2.4.
set fairing to true.
set s_T to burn.

peg_ascent(pe, ap, u, inc, kick_start, kick_end, kick, hdg).

stage.
wait 20.
deorbit().
