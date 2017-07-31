copy peg_lib from archive.
run once peg_lib.

declare parameter pe to 130.
declare parameter ap to 130.
declare parameter inc to -28.8.
declare parameter u to 0.
declare parameter kick_start is 12.
declare parameter kick_end is 40.
declare parameter kick is 16.
declare parameter burn is 200.
declare parameter hdg to 90.

set peg_eps to 8.
set peg_gcap to 2.2.
set fairing to true.
set s_T to burn.

peg_ascent(pe, ap, u, inc, kick_start, kick_end, kick, hdg).

