copy peg_lib from archive.
run once peg_lib.

declare parameter pe to 240.
declare parameter ap to 800.
declare parameter inc to -97.
declare parameter u to 0.
declare parameter kick_start is 8.
declare parameter kick_end is 45.
declare parameter kick is 16.
declare parameter burn is 300.
declare parameter hdg to 190.

set peg_eps to 12.
set peg_gcap to 3.
set fairing to False.
set s_T to burn.

peg_ascent(pe, ap, u, inc, kick_start, kick_end, kick, hdg).

wait 3.
set AG1 to True.
stage.
stage.
