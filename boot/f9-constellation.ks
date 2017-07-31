wait 5.
copypath("0:/peg_lib", "").
copypath("0:/exec_lib", "").
run once peg_lib.
run once exec_lib.

declare parameter pe to 160.
declare parameter ap to 2000.
declare parameter inc to 45.
declare parameter u to 0.
declare parameter kick_start is 17.
declare parameter kick_end is 45.
declare parameter kick is 18.
declare parameter burn is 200.
declare parameter hdg to -1.

set peg_launchcap to 0.9.

set peg_eps to 8.
set peg_meco_ap to 120.
set peg_maxqdip to 0.8.
set peg_gcap to 2.2.
set fairing to true.
set s_T to burn.

peg_ascent(pe, ap, u, inc, kick_start, kick_end, kick, hdg).

wait 300.
circularize().
exec(0.5, 0.5).

set AG1 to true.
wait 5.
avoid(1).
wait 5.
set AG2 to true.
wait 5.
avoid(1).
wait 5.
set AG3 to true.
wait 5.
avoid(3).
wait 10.
deorbit().

