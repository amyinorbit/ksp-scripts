wait 5.
copypath("0:/peg_lib", "").
run once peg_lib.

declare parameter pe to 300.
declare parameter ap to 600.
declare parameter inc to -95.
declare parameter u to 0.
declare parameter kick_start is 33.
declare parameter kick_end is 70.
declare parameter kick is 15.
declare parameter burn is 300.
declare parameter hdg to 155.

set peg_boosters to 0.
set peg_eps to 12.
set peg_gcap to 4.0.
set peg_maxqdip to 1.0.
set fairing to true.
set s_T to burn.

peg_ascent(pe, ap, u, inc, kick_start, kick_end, kick, hdg).

