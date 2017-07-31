declare function exec {
    declare parameter precision.
    declare parameter max_thr to 1.0.
    
    set nd to nextnode.
    clearscreen.
    print "Next burn scheduled: " + round(nd:eta).

    local g_thr is 0.
    lock throttle to g_thr.

    local max_acc is (max_thr * ship:maxthrust)/ship:mass.
    local duration is nd:deltav:mag/max_acc.
    local margin is (nd:deltav:mag / 100) * precision.

    print "Estimated Burn Time: "+round(duration)+"s".

    wait until nd:eta <= (duration/2 + 30).
    set burn_vector to nd:deltav.
    lock steering to burn_vector.

    wait until abs(burn_vector:direction:pitch - facing:pitch) < 0.15 and abs(burn_vector:direction:yaw - facing:yaw) < 0.15.

    print "Alignment Maneuver Complete".
    wait until nd:eta <= (duration/2).
    set done to False.

    until done {
        set max_acc to ship:maxthrust/ship:mass.
        set g_thr to max_thr * min(nd:deltav:mag/max_acc, 1).
    
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
    set ship:control:neutralize to true.
    set ship:control:pilotmainthrottle to 0.
}

function avoid {
    declare parameter duration to 0.5.
    
    local g_thr is 0.
    lock throttle to g_thr.
    lock steering to ship:prograde.
    
    rcs on.
    set ship:control:fore to -1.0.
    wait duration.
    set ship:control:neutralize to true.
    wait 2.
}

declare function circularize {
    set burn_vector to ship:prograde.

    set r_ap to ship:apoapsis + orbit:body:radius.
    set act_vx to sqrt(orbit:body:mu * ((2/r_ap)-(1/ship:obt:semimajoraxis))).
    set tgt_vx to orbit:body:radius * sqrt(9.8/r_ap).

    set tgt_dv to tgt_vx - act_vx.
    
    set node to Node(time:seconds + eta:apoapsis, 0, 0, tgt_dv).
    add node.
}

declare function deorbit {
    print "Starting Deorbit Maneuver.".
    local g_thr is 0.
    lock throttle to g_thr.
    set burn_vector to ship:retrograde.
    lock steering to burn_vector.
    wait until abs(burn_vector:pitch - facing:pitch) < 0.15 and abs(burn_vector:yaw - facing:yaw) < 0.15.
    
    wait 5.
    set g_thr to 1.
    wait until ship:periapsis < 20000.
    set g_thr to 0.
    
    unlock throttle.
    unlock steering.
    set ship:control:neutralize to true.
    set ship:control:pilotmainthrottle to 0.
}
