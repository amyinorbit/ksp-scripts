function atmo_getHeading {
    return Body:GeoPositionOf(Ship:Position +Ship:Velocity:Surface):Heading.
}

function atmo_getPitch {
    return 90 - VectorAngle(Up:ForeVector, Facing:ForeVector).
}

function atmo_getSlope {
    return 90 - VectorAngle(Up:ForeVector, Ship:Velocity:Surface).
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

function rentryGuidance {
    declare parameter aoa.
    declare parameter bank.
    
    local vel is Ship:Velocity:Surface.
    local bankUp is Ship:Up * angleAxis(bank, vel).
    local rotate is vectorCrossProduct(bankUp, vel).
    
    
}
    
function entryAoA {
    declare parameter aoa.
    return heading(atmo_getHeading(), atmo_getSlope() + aoa).
}

lock steering to entryAoA(20).
wait until altitude < 30000.
lock steering to entryAoA(3).
wait until altitude < 2000.