wait 5.
copypath("0:/peg_lib", "").
run once peg_lib.

declare parameter pe to 130.
declare parameter ap to 350.
declare parameter inc to -28.6.
declare parameter u to 0.
declare parameter kick_start is 18.
declare parameter kick_end is 60.
declare parameter kick is 22.8.
declare parameter burn is 200.
declare parameter hdg to 90.5.

set peg_launchcap to 1.0.

set peg_eps to 8.
set peg_meco_ap to 105.
set peg_maxqdip to 0.9.
set peg_gcap to 3.0.
set fairing to true.
set s_T to burn.

peg_ascent(pe, ap, u, inc, kick_start, kick_end, kick, hdg).

