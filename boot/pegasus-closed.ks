global g_pegasus_launch is 0.


function atmo_getHeading {
    return Body:GeoPositionOf(Ship:Position +Ship:Velocity:Surface):Heading.
}

function atmo_getPitch {
    return 90 - VectorAngle(Up:ForeVector, Facing:ForeVector).
}

function atmo_getRoll {
    return -(90 - Vectorangle(Up:Vector, Ship:Facing:StarVector)).
}

function atmo_angleDiff {
    declare parameter y.
    declare parameter x.
    
    local a is x - y.
    if(a > 180) {
        return a - 360.
    }
    if(a < -180) {
        return a + 360.
    }
    return a.
}
    
set hdgToRoll to pidLoop(1.5, 0, 0, -25, 25).
set rollToStick to pidLoop(0.01, 0.0, 0.01, -0.5, 0.5).

set pitchToStick to pidLoop(0.02, 0.02, 0.01, -1, 1).

set speedToThr to pidLoop(0.03, 0.01, 0.1, 0, 1).


function atmo_lockHdg {
    declare parameter hdg.
    
    local stick is SHIP:CONTROL.
    set hdgToRoll:setpoint to 0.
    
    local roll is hdgToRoll:update(time:seconds, atmo_angleDiff(hdg, atmo_getHeading())).
    set rollToStick:setPoint to roll.
    set stick:roll to rollToStick:update(time:seconds, atmo_getRoll()).
}

function atmo_lockPitch {
    declare parameter pitch.
    local stick is Ship:Control.
    
    
    set pitchToStick:setPoint to pitch.
    set stick:pitch to pitchToStick:update(time:seconds, atmo_getPitch()).
}



/// END OF ATMO LIBRARY


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
    declare parameter inc.
    declare parameter duration.
    declare parameter bend_end to 20.
    declare parameter bend_angle to 50.
    
    local met is 0.
    lock met to mission_time().
    
    pegasus_msg("drop").
    stage.
    set ship:control:neutralize to true.
    unlock steering.
    wait 3.
    stage.
    
    local boost_start is mission_time().
    pegasus_msg("ignition").
    
    until met > bend_end {
        set t to (met - boost_start)/(bend_end-boost_start).
        set pitch to t*bend_angle.
        
        atmo_lockPitch(pitch).
        atmo_lockHdg(inst_az(inc, tgt_vx)).
    }

    pegasus_msg("lift vector correction").
    until met > (boost_start + duration) {
        atmo_lockPitch(bend_angle).
        atmo_lockHdg(inst_az(inc, tgt_vx)).
    }
    set ship:control:neutralize to true.
    
    pegasus_msg("q-alpha steering").
    lock steering to ship:velocity:surface.
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
    declare parameter pe to 140.
    declare parameter ap to 300.
    declare parameter u to 0.
    declare parameter inc to -28.6.

    clearscreen.
    pegasus_msg("waiting for drop").
    wait until ag1.

    peg_init(150, ap, u, inc).
    set g_pegasus_launch to missiontime.
    pegasus_dropboost(inc, 60, 20, 40).
    pegasus_msg("done").
    pegasus_coaststage(80).
    pegasus_burn(40, 20).
    stage.
    wait 1.
    stage.
    set g_thr to 1.
    set g_steer to ship:velocity:surface.
    lock throttle to g_thr.
    lock steering to g_steer.
    peg_closedloop().
}

copypath("0:/peg_lib", "").
run once peg_lib.
copypath("0:/az", "").
run once az.
main(140, 600, 0, 45).