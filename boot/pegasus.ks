global g_pegasus_launch is 0.


declare function mission_time {
    return missiontime - g_pegasus_launch.
}

declare function pegasus_msg {
    declare parameter message.
    print "pegasus [T+"+round(+mission_time(), 0)+"]: "+message.
}

declare function pegasus_predrop {
    declare parameter hdg.
    lock steering to heading(hdg, 8).
    wait 10.
}

declare function pegasus_dropboost {
    declare parameter hdg.
    declare parameter duration.
    declare parameter bend_end to 20.
    declare parameter hold_end to 40.
    declare parameter bend_angle to 50.
    
    local met is 0.
    lock met to mission_time().
    
    pegasus_msg("drop").
    stage.
    unlock steering.
    wait 3.
    stage.
    
    local boost_start is mission_time().
    pegasus_msg("ignition").
    
    until met > bend_end {
        set t to (met - boost_start)/(bend_end-boost_start).
        set pitch to t*bend_angle.
        
        lock steering to heading(hdg, pitch).
    }
    pegasus_msg("lift vector correction").
    wait until met > hold_end.
    
    pegasus_msg("q-alpha steering").
    lock steering to ship:velocity:surface.
    wait until met > (boost_start + duration).
}

declare function pegasus_coaststage {
    declare parameter next_event.
    
    local met is 0.
    lock met to mission_time().
    pegasus_msg("coast enable").
    
    when met > (next_event - 2) then {
        stage.
    }
    wait until met > next_event.
}

declare function pegasus_burn {
    declare parameter duration.
    declare parameter ditch to -1.
    
    stage.
    
    local met is 0.
    lock met to mission_time().
    
    local burn_start is met.
    pegasus_msg("ignition").
    
    if(ditch > 0 and ditch < duration) {
        wait until met > (burn_start + ditch).
        stage.
    }
    
    wait until met > (burn_start + duration).
}

declare function main {
    declare parameter hdg.

    clearscreen.
    pegasus_msg("waiting for drop").
    wait until ag1.
    
    pegasus_predrop(hdg).
    set g_pegasus_launch to missiontime.
    pegasus_dropboost(hdg, 60, 20, 40, 45).
    pegasus_msg("done").
    pegasus_coaststage(90).
    pegasus_burn(40, 20).
    //pegasus_coaststage(235).
    //pegasus_burn(20).
}


main(90).