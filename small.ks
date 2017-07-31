copy peg_lib from archive.
run once peg_lib.

declare parameter pe to 130.
declare parameter ap to 200.
declare parameter inc to -28.8.
declare parameter u to 0.
declare parameter kick_start is 15.
declare parameter kick_end is 50.
declare parameter kick is 17.
declare parameter burn is 100.
declare parameter hdg to 90.

set peg_eps to 12.
set peg_gcap to 2.1.
set peg_maxqdip to 0.8.
set fairing to true.
set s_T to burn.

peg_ascent(pe, ap, u, inc, kick_start, kick_end, kick, hdg).
