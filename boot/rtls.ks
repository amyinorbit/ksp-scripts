wait 5.
copypath("0:/lib_spacex", "").
run once lib_spacex.

clearscreen.
print "/// f9_rtls".
print "booster shadow GNC enable".

local offset is 0.

wait until altitude > 30000.
if hasTarget {
    set tgt to target:geoposition.
    set offset to 3.2391.
}
else {
    // VAB rooftop
    set tgt to latlng(28.60836982727051, -19.7030277252197).
    // HAB parking lot
    //set tgt to latlng(28.6136798858643, -19.7031173706055).
}
print "recovery AOS".

waitForStage(2).
doFlip(-1, 6).
wait 1.
doBoostBack(4, 0.5).

set ag9 to true.

doFlip(1, 0.15).
wait 1.
doFlip(1, 0.15).
waitForRetrograde(10).
doEntry(45000, 15, 0.4).
//toggle ag10.
doLanding(offset).
