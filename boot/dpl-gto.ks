wait 5.
copypath("0:/lib_spacex", "").
run once lib_spacex.
clearscreen.
print "booster shadow mode enable".

wait until altitude > 30000.

set tgt to target:geoposition.
print "recovery AOS".

waitForStage(10).
doFlip(-0.25, 0.75).
wait 10.
set ag9 to true.
waitForRetrograde(10).
doEntry(50000, 25, 0.6).
doLanding(2).
