wait 5.
copypath("0:/peg_lib", "").
copypath("0:/exec_lib", "").
run once peg_lib.
run once exec_lib.

toggle ag1.
toggle ag2.

declare parameter pe to 150.
declare parameter ap to 200.
declare parameter inc to 51.6.
declare parameter u to 0.
declare parameter kick_start is 27.
declare parameter kick_end is 60.
declare parameter kick is 18.
declare parameter burn is 280.
declare parameter hdg to 43.7.

set peg_eps to 8.
set peg_meco_ap to 125.
set peg_maxqdip to 1.0.
set peg_gcap to 10.
set fairing to true.
set s_T to burn.

when ship:altitude > 42000 then {
    toggle ag10.
}

peg_ascent(pe, ap, u, inc, kick_start, kick_end, kick, hdg).
wait 10.
toggle ag5.
stage.
wait 60.
set ship:control:pitch to 1.0.
wait 0.5.
set ship:control:pitch to 0.0.
wait 10.
deorbit().

