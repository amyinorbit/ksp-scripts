global tgt is ship:geoposition.
global oldD is 0.
global oldT is time:seconds.
global g_eng is list().
global stage_thrust is 0.

set SteeringManager:ROLLCONTROLANGLERANGE to 180.

function waitDir {
    declare parameter targetDir.
    declare parameter margins to 5.
    wait until abs(targetDir:pitch - facing:pitch) < margins and abs(targetDir:yaw - facing:yaw) < margins.
    lock steering to targetDir.
}

function timeToImpact {
    local v0 is ship:verticalspeed.
    local z0 is ship:altitude.
    local grav is 9.81.
    
    local sq is sqrt(2*grav*z0 + (v0*v0)).
    
    local t1 is (-v0 + sq)/grav.
    local t2 is (-v0 - sq)/grav.
    
    
    if(t1 <= 0) {
        return -t1.
    }
    else if(t2 <= 0) {
        return -t2.
    }
    else {
        return -1.
    }
}

declare function getHeading {
    return Body:GeoPositionOf(Ship:Position +Ship:Velocity:Surface):Heading.
}

function boostbackParams {
    declare parameter bbpitch to 0.

    local tti is timeToImpact().
    
    local dist is geoDistance(ship:geoposition, tgt).
    local optiVel is dist / tti.
    
    local tgtVel is optiVel * heading(tgt:heading, 0):foreVector:normalized.
    local curVel is groundSpeed * heading(getHeading() , 0):foreVector:normalized.
    local burnvec is (tgtVel - curVel).
    local rotAxis to vectorCrossProduct(burnVec, ship:up:foreVector).
    local rot is angleAxis(bbPitch, rotAxis).
    return List(burnVec:normalized * rot, burnVec:mag).
}

function impactPoint {
    local tti is timeToImpact().
    
    local impactUT is time + tti.
    local impactVec is positionat(ship, impactUT).
    

    local ll is body:geoPositionOf(impactVec).
    local lon is ll:lng - (body:angularVel:mag * Constant:RadToDeg * tti).
    
    return latlng(ll:lat, lon).
}

function aeroImpactPoint {
    if Addons:TR:hasImpact {
        return Addons:TR:ImpactPos.
    }
    else {
        return ship:geoposition.
    }
}

function geoDistance {
    declare parameter p1, p2.
    local radius is body:radius.
    set resultA to sin((p1:lat-p2:lat)/2)^2 + cos(p1:lat)*cos(p2:lat)*sin((p1:lng-p2:lng)/2)^2.
    return radius*constant():PI*arctan2(sqrt(resultA),sqrt(1-resultA))/90.
}

function geoBearing {
    declare parameter p1,p2. //point 1 and point 2
    return arctan2(sin(p2:lng-p1:lng)*cos(p2:lat),cos(p1:lat)*sin(p2:lat)-sin(p1:lat)*cos(p2:lat)*cos(p2:lng-p1:lng)).
}

function steerMult {
    declare parameter boost to false.
    if boost and altitude < 10000 {
        return 5.
    }
    if altitude > 100000 {
        return 0.
    }
    return 5 * ((1 - (altitude/100000))^2).
}

function limitNum {
    declare parameter value.
    declare parameter lim.
    return max(min(value, lim), -lim).
}

function steerLimits {
    declare parameter value.
    declare parameter boost to false.
    
    if boost and altitude > 10000 or alt:radar < 40 {
        return limitNum(value, 2).
    }
    return limitNum(value, 10).
}

function boostMult {
    local v is ship:velocity:surface:mag.
    if alt:radar > 12000 { return -1. }
    if v > 140 { return 1. }
    if v < 100 { return -1. }
    return (v - 120) / 20.
}

function aeroSteer {
    parameter boost is false.
    
    local iip is aeroImpactPoint().
    local KP is 0.1.
    local KD is 0.01.
    
    if boost and alt:radar < 8000 {
        set KP to 0.1.
        set KD to 0.02.
    }
    
    local brg is geoBearing(iip, tgt).
    local err is geoDistance(iip, tgt).
    
    clearscreen.
    print "error: "+round(err, 2)+"m".
    
    local dt is time:seconds - oldT.
    set oldT to time:seconds.
    local dxdt is (err - oldD) / dt.
    local vec is heading(brg, 0):foreVector.
    local rotateAxis is vectorCrossProduct(ship:velocity:surface, vec).
    local strength is (err * KP + dxdt * KD) * steerMult().
    
    if boost  {
        local m is boostMult().
        set strength to strength * m.
    }
    
    set strength to steerLimits(strength, boost).
    set oldD to err.
    local rot is angleAxis(strength, rotateAxis).
    
    if boost and alt:radar < 10000 {
        return LOOKDIRUP(ship:up:foreVector * rot, ship:north:forevector).
    } else {
        return LOOKDIRUP((-1 * ship:velocity:surface) * rot, ship:north:forevector).
    }
}

function waitForStage {
    declare parameter waitTime to 3.
    
    wait until ag5.
    wait waitTime.
    set ag8 to true.
    rcs on.
}

function waitForRetrograde {
    declare parameter margins to 10.
    wait until abs(srfRetrograde:pitch- facing:pitch) < margins and abs(srfRetrograde:yaw - facing:yaw) < margins.
    lock steering to srfRetrograde.
}

function doFlip {
    // This could be interesting
    // https://www.reddit.com/r/Kos/comments/3ivlz9/
    declare parameter dir to -1.
    declare parameter strength to 5.
    
    set Ship:Control:pitch to dir.
    wait strength.
    set Ship:Control:pitch to 0.
    set ship:control:neutralize to true.
}

function waitAndLockBB {
    declare parameter bbPitch to 0.
    local bbParams is boostbackParams(bbPitch).
    waitDir(bbParams[0]:direction, 20).
    lock steering to bbParams[0].
}

function doBoostBack {
    declare parameter bbDelay to 0.
    declare parameter bbFactor to 0.5.
    declare parameter bbPitch to 0.
    
    
    local bbParams is boostbackParams(bbPitch).
    set bbParams to boostbackParams(bbPitch).
    lock steering to bbParams[0].
    
    wait bbDelay.

    print("boostback startup").
    lock throttle to 1.
    
    wait 3.
    toggle ag10.
    
    until bbParams[1] < 50 {
        set bbParams to boostbackParams(bbPitch).
    }
    toggle ag10.
    until bbParams[1] < 40 {
        set bbParams to boostbackParams(bbPitch).
    }
    wait 4 * bbFactor.
    print("boostback shutdown").
    lock throttle to 0.
    
    wait 10.
    unlock steering.
}

function doEntry {
    declare parameter entryAlt to 50000.
    declare parameter entryDuration to 8.
    declare parameter level to 0.6.

    wait until altitude < 70000.
    lock steering to lookDirUp(srfRetrograde:foreVector, ship:north:foreVector).
    
    if entryDuration = 0 {
        return.
    }
    
    wait until altitude < entryAlt.
    
    print("reentry startup").
    lock steering to aeroSteer(true).
    lock throttle to level.
    
    wait 2.
    toggle ag10.
    
    wait entryDuration - 4.
    toggle ag10.
    lock steering to lookDirUp(srfRetrograde:foreVector, ship:north:foreVector).
    wait 2.
    
    lock throttle to 0.
    print("reentry shutdown").
    lock steering to aeroSteer().
    //rcs off.
}

function doEntryGTO {
    declare parameter entryAlt to 50000.

    wait until altitude < 70000.
    lock steering to lookDirUp(srfRetrograde:foreVector, ship:north:foreVector).
    
    wait until altitude < entryAlt.
    
    print("reentry startup").
    local bbParams is boostbackParams(30).
    lock steering to bbParams[0].
    lock bbParams to boostbackParams(30).

    print("boostback startup").
    lock throttle to 1.
    
    wait 3.
    toggle ag10.
    
    wait until bbParams[1] < 50.
    toggle ag10.
    wait until bbParams[1] < 10.
    lock throttle to 0.
    print("reentry shutdown").
    lock steering to aeroSteer().
}

function throttleLimits {
    declare parameter command.
    return max(min(1.0, command), 0.5).
}

function doLanding {
    declare parameter platformOffset to 7.2311.
    declare parameter radarOffset to 33.829.
    
    // and ship:velocity:surface:mag < 280
    wait until altitude < 8000.
    list engines in g_eng.
    
    // modified from this:
    // https://github.com/mrbradleyjh/kOS-Hoverslam/blob/master/hoverslam.ks
    
    lock trueRadar to alt:radar - (radarOffset + platformOffset).
    lock g to constant:g * body:mass / body:radius^2.
    lock maxDecel to (ship:availablethrust / ship:mass) - g.
    lock stopDist to ship:verticalspeed^2 / (2 * maxDecel).
    lock idealThrottle to throttleLimits(stopDist / trueRadar).
    

    wait until trueRadar < stopDist.
    
    print("landing startup").
    lock throttle to idealThrottle.
    lock steering to aeroSteer(true).

    when alt:radar < 220 then {
        set gear to true.
    }
    
    wait until status = "LANDED" or verticalspeed > -0.5.
    unlock steering.

    for e in g_eng {
        if e:ignition and e:allowshutdown {
            e:shutdown.
        }
    }
    lock throttle to 0.
    unlock throttle.

    print("landing shutdown").
    print("landed at ("+(latitude)+","+(longitude)+")").
}