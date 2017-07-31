function atmo_getHeading {
    return Body:GeoPositionOf(Ship:Position +Ship:Velocity:Surface):Heading.
}

function atmo_getPitch {
    return 90 - VectorAngle(Up:ForeVector, Facing:ForeVector).
}

function atmo_getRoll {
    return -(90 - Vectorangle(Up:Vector, Ship:Facing:StarVector)).
}

    
set hdgToRoll to pidLoop(1.5, 0, 0, -30, 30).
set rollToStick to pidLoop(0.02, 0.01, 0.01, -0.5, 0.5).

set altToVrate to pidLoop(0.05, 0, 0, -500, 50).
set vrateToPitch to pidLoop(1, 0.5, 0, -10, 40).
set pitchToStick to pidLoop(0.02, 0.02, 0.01, -0.5, 0.5).

set speedToThr to pidLoop(0.03, 0.01, 0.03, 0, 1).


function atmo_lockHdg {
    declare parameter hdg.
    
    local stick is SHIP:CONTROL.
    set hdgToRoll:setpoint to hdg.
    
    local roll is hdgToRoll:update(time:seconds, atmo_getHeading()).
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

stage.
until ship:altitude > 1000 {
    clearscreen.
    atmo_lockHdg(90).
    atmo_lockThrottle(150).
    atmo_lockVZ(30).
    wait 0.1.
}

until ship:altitude > 3000 {
    clearscreen.
    atmo_lockThrottle(250).
    atmo_lockHdg(270).
    atmo_lockAltitude(10000).
    wait 0.1.
}

until ship:airspeed > 300 {
    atmo_lockHdg(320).
    atmo_lockVZ(20).
    atmo_lockThrottle(300).
}

