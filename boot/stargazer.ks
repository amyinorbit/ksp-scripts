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
    
set hdgToRoll to pidLoop(2.5, 0, 0, -30, 30).
set rollToStick to pidLoop(0.02, 0.0, 0.02, -0.5, 0.5).

set altToVrate to pidLoop(0.1, 0.0, 0.02, -30, 40).
set vrateToPitch to pidLoop(1, 0.3, 0, -10, 40).
set pitchToStick to pidLoop(0.02, 0.02, 0.01, -0.5, 0.5).

set speedToThr to pidLoop(0.03, 0.01, 0.03, 0, 1).


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

function atmo_lockVZ {
    declare parameter vrate.
    
    local stick is Ship:Control.
    set vrateToPitch:setpoint to vrate.
    
    local pitch is vrateToPitch:update(time:seconds, verticalspeed).
    print "pitch: "+round(pitch, 2)+"/"+round(atmo_getPitch(), 2).
    set pitchToStick:setPoint to pitch.
    set stick:pitch to pitchToStick:update(time:seconds, atmo_getPitch()).
}

copypath("0:/az", "").
run once az.

wait until ag9.

set target_inc to -45.

stage.
lock throttle to 1.
lock steering to heading(90, 0).
wait until ship:airspeed > 100.
lock steering to heading(90, 10).
wait 10.
unlock steering.
set gear to false.

until ship:altitude > 1000 {
    clearscreen.
    atmo_lockHdg(90).
    atmo_lockThrottle(250).
    atmo_lockVZ(30).
    wait 0.05.
}

until ship:airspeed > 240 {
    clearscreen.
    atmo_lockThrottle(250).
    atmo_lockHdg(launch_az(target_inc)).
    atmo_lockVZ(30).
    wait 0.05.
}

set ag10 to true.

until (ship:altitude > 11990
       and ag8
       and atmo_getHeading() > (launch_az(target_inc) - 1)
       and atmo_getHeading() < (launch_az(target_inc) + 1)) {
    clearscreen.
    atmo_lockThrottle(310).
    atmo_lockHdg(launch_az(target_inc)).
    atmo_lockAltitude(12100).
    wait 0.1.
}

set ag1 to true.
wait 10.

until false {
    atmo_lockThrottle(310).
    atmo_lockHdg(90).
    atmo_lockAltitude(12100).
    clearscreen.
}
