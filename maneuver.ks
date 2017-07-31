declare parameter precision.

set nd to nextnode.
print "Next burn scheduled: " + round(nd:eta).

set max_acc to ship:maxthrust/ship:mass.
set duration to nd:deltav:mag/max_acc.

set margin to (nd:deltav:mag / 100) * precision.

print "Estimated Burn Time: "+round(duration)+"s".

wait until nd:eta <= (duration/2 + 90).

set burn_vector to nd:deltav.
lock steering to burn_vector.

wait until abs(burn_vector:direction:pitch - facing:pitch) < 0.15 and abs(burn_vector:direction:yaw - facing:yaw) < 0.15.

print "Alignment Maneuver Complete".

wait until nd:eta <= (duration/2).

set tset to 0.
lock throttle to tset.

set done to False.

until done {
    set max_acc to ship:maxthrust/ship:mass.
    set tset to min(nd:deltav:mag/max_acc, 1).
    
    lock steering to nd:deltav.
    
    if(nd:deltav:mag < margin) {
        lock throttle to 0.
        print "Engine Cutoff".
        set done to True.
    }
}

lock steering to ship:prograde.
unlock throttle.
remove nd.
wait 10.
set AG1 to True.

//set throttle to 0 just in case.
set ship:control:pilotmainthrottle to 0.