wait 5.
copypath("0:/peg_lib", "").
run once peg_lib.

declare parameter pe to 130.
declare parameter ap to 100.
declare parameter inc to -28.6.
declare parameter u to 0.
declare parameter kick_start is 2.
declare parameter kick_end is 34.
declare parameter kick is 30.5.
declare parameter burn is 300.
declare parameter hdg to 90.

set peg_boosters to 3.
set peg_eps to 12.
set peg_gcap to 4.0.
set peg_maxqdip to 0.7.
set fairing to true.
set s_T to burn.

peg_ascent(pe, ap, u, inc, kick_start, kick_end, kick, hdg).

