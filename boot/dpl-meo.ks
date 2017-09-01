wait 5.
copypath("0:/lib_spacex", "").
run once lib_spacex.
clearscreen.
print "booster shadow mode enable".

wait until altitude > 30000.

set tgt to target:geoposition.
print "recovery AOS".


waitForStage(1).
local stageVec is ship:facing.
wait 3.
lock steering to stageVec.
wait 10.
unlock steering.
set ag9 to true.
wait 20.
doFlip(-0.25, 0.25).
wait until ship:altitude < 100000.
doEntry(70000, 30, 0.5).
doLanding(2).
