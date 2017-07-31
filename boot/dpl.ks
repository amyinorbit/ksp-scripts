wait 5.
copypath("0:/lib_spacex", "").
run once lib_spacex.

clearscreen.
print "/// f9_dpl_boostback".
print "booster shadow GNC enable".

wait until altitude > 30000.
set tgt to target:geoposition.
print "recovery AOS".


waitForStage(2).
doFlip(-1, 7).
wait 1.
doBoostBack(4, 0.3, -20).


doFlip(0.25, 0.75).
set ag9 to true.
wait until altitude < 60000.
//doBoostBack(4, 0.3, 60).
doEntry(50000, 15, 0.4).

doLanding(2).
