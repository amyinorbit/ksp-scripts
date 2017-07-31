global tgt is ship:geoposition.
global oldD is 0.
global oldT is time:seconds.
global g_eng is list().
global stage_thrust is 0.

declare function getHeading {
    return Body:GeoPositionOf(Ship:Position +Ship:Velocity:Surface):Heading.
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
    if altitude > 70000 {
        return 0.
    }
    return 5 * ((1 - (altitude/70000))^2).
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
        return limitNum(value, 10).
    }
    return limitNum(value, 15).
}

function boostMult {
    local v is ship:velocity:surface:mag.
    if alt:radar > 12000 { return -1. }
    if v > 160 { return 1. }
    if v < 120 { return -1. }
    return (v - 140) / 40.
}


function aeroSteer {
    parameter boost is false.
    
    local iip is aeroImpactPoint().
    local KP is 0.02.
    local KD is 0.01.
    
    if boost and alt:radar < 8000 {
        set KP to 0.06.
        set KD to 0.
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

function throttleLimits {
    declare parameter command.
    return max(min(1.0, command), 0.2).
}

declare function neutral {
    return ship:mass*9.81 / ship:availablethrust.
}


function doLanding {
    declare parameter platformOffset to 7.2311.
    declare parameter radarOffset to 33.829.
    
    list engines in g_eng.
    
    
    wait until alt:radar < 3000.
    // modified from this:
    // https://github.com/mrbradleyjh/kOS-Hoverslam/blob/master/hoverslam.ks
    
    lock trueRadar to (alt:radar - (radarOffset + platformOffset)) - 50.
    lock g to constant:g * body:mass / body:radius^2.
    lock maxDecel to (ship:availablethrust / ship:mass) - g.
    lock stopDist to (ship:verticalspeed^2 / (2 * maxDecel)).
    lock idealThrottle to throttleLimits(stopDist / trueRadar).
    

    wait until trueRadar < stopDist.
    
    print("landing startup").
    lock throttle to idealThrottle.
    lock steering to aeroSteer(true).

    when alt:radar < 220 then {
        set gear to true.
    }
    
    wait until verticalspeed > -20.
    
    local throttle_pid to pidloop(.05, 0, 0.01, -1, 1).
    set throttle_pid:setpoint to -2.
    lock throttle to throttleLimits(neutral() + throttle_pid:update(time:seconds, verticalspeed)).
    
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

wait 5.
set tgt to latlng(28.6136798858643, -19.7031173706055).
//set tgt to latlng(28.60836982727051, -19.7030277252197).

lock throttle to 0.
stage.
lock throttle to 0.5.
wait 2.
stage.
lock throttle to 1.0.
lock steering to ship:up.
wait until apoapsis > 85000.
lock throttle to 0.0.
unlock throttle.
wait until altitude > 60000.
stage.
wait until verticalspeed < -10.
wait until altitude < 70000.
toggle ag10.
lock steering to aeroSteer().
doLanding(0, 14).
