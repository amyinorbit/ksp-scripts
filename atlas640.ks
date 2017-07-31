copy peg_lib from archive.
run once peg_lib.

declare parameter pe to 300.
declare parameter ap to 1500.
declare parameter inc to -90.
declare parameter u to 0.
declare parameter kick_start is 28.
declare parameter kick_end is 60.
declare parameter kick is 9.
declare parameter burn is 300.
declare parameter hdg to -1.

set peg_eps to 12.
set peg_gcap to 2.1.
set fairing to true.
set s_T to burn.

peg_ascent(pe, ap, u, inc, kick_start, kick_end, kick, hdg).

