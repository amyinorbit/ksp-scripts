wait 5.
copypath("0:/peg_lib", "").
run once peg_lib.

set ag1 to true.
set ag2 to true.


set SteeringManager:ROLLCONTROLANGLERANGE to 180.

declare parameter pe to 150. // RTLS
//declare parameter pe to 168. // DPL
declare parameter ap to 200.
declare parameter inc to 51.6.
//declare parameter inc to -28.8.
declare parameter u to 0.
declare parameter kick_start is 19.
declare parameter kick_end is 55.
//declare parameter kick is 14.
declare parameter kick is 14.
declare parameter burn is 200.
declare parameter hdg to 43.7.
//declare parameter hdg to 136.3.

set peg_launchcap to 1.0.

set peg_eps to 8.
set peg_meco_ap to 90. // RTLS
//set peg_meco_ap to 100. // DPL
set peg_maxqdip to 0.8.
set peg_gcap to 3.5.
set fairing to false.
set s_T to burn.

peg_ascent(pe, ap, u, inc, kick_start, kick_end, kick, hdg).

