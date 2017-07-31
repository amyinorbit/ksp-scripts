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
set rollToStick to pidLoop(0.02, 0.01, 0.01, -0.5, 0.5).

set altToVrate to pidLoop(0.5, 0, 0, -50, 50).
set vrateToPitch to pidLoop(1, 0.5, 0, -60, 60).
set pitchToStick to pidLoop(0.02, 0.02, 0.01, -1, 1).

set speedToThr to pidLoop(0.03, 0.01, 0.1, 0, 1).


function atmo_lockHdg {
    declare parameter hdg.
    
    local stick is SHIP:CONTROL.
    set hdgToRoll:setpoint to 0.
    
    local roll is hdgToRoll:update(time:seconds, atmo_angleDiff(hdg, atmo_getHeading())).
    print "roll:  "+round(roll, 2)+"/"+round(atmo_getRoll(), 2).
    set rollToStick:setPoint to roll.
    set stick:roll to rollToStick:update(time:seconds, atmo_getRoll()).
}

function atmo_lockAltitude {
    declare parameter alt.
    
    local stick is Ship:Control.
    set altToVrate:setpoint to alt.
    
    print "alt:   "+round(alt, 2)+"/"+round(ship:altitude, 2).
    local vrate to altToVrate:update(time:seconds, ship:altitude).
    print "vrate: "+round(vrate, 2)+"/"+round(verticalspeed, 2).
    set vrateToPitch:setpoint to vrate.
    local pitch is vrateToPitch:update(time:seconds, verticalspeed).
    print "pitch: "+round(pitch, 2)+"/"+round(atmo_getPitch(), 2).
    set pitchToStick:setPoint to pitch.
    set stick:pitch to pitchToStick:update(time:seconds, atmo_getPitch()).
}

function atmo_lockRadar {
    declare parameter height.
    
    local talt is (ship:altitude - alt:radar) + height.
    atmo_lockAltitude(talt).
}

function atmo_lockThrottle {
    declare parameter speed.
    
    local stick is Ship:Control.
    set speedToThr:setpoint to speed.
    
    local thr is speedToThr:update(time:seconds, ship:airspeed).
    set stick:MainThrottle to thr.
}

function atmo_lockVRate {
    declare parameter vrate.
    
    local stick is Ship:Control.
    set vrateToPitch:setpoint to vrate.
    
    local pitch is vrateToPitch:update(time:seconds, verticalspeed).
    print "pitch: "+round(pitch, 2)+"/"+round(atmo_getPitch(), 2).
    set pitchToStick:setPoint to pitch.
    set stick:pitch to pitchToStick:update(time:seconds, atmo_getPitch()).
}

set target_hdg to 90.
set target_alt to 0.
set target_spd to 100.

until 0 {
    

    clearscreen.
    print "hdg:   "+round(target_hdg, 2)+"/"+round(atmo_getHeading(), 2).
    print "alt:   "+round(target_alt, 2)+"/"+round(ship:altitude, 2).
    print "spd:   "+round(target_spd, 2)+"/"+round(ship:airspeed, 2).
    
    if ag1 {
        atmo_lockHdg(target_hdg).
        if(target_alt > 1000) {
            atmo_lockAltitude(target_alt).
        } else {
            atmo_lockRadar(target_alt).
        }
        
        atmo_lockThrottle(target_spd).
    }
    if ag4 {
        set target_hdg to target_hdg - 1.
    }
    if ag5 {
        set target_hdg to target_hdg + 1.
    }
    if ag6 {
        set target_alt to target_alt - 10.
    }
    if ag7 {
        set target_alt to target_alt + 10.
    }
    if ag8 {
        set target_spd to target_spd - 1.
    }
    if ag9 {
        set target_spd to target_spd + 1.
    }
    if target_alt < 10 {
        set target_alt to 10.
    }
    if target_hdg < 0 {
        set target_hdg to target_hdg + 360.
    }
    if target_hdg > 360 {
        set target_hdg to target_hdg - 360.
    }
    wait .1.
}