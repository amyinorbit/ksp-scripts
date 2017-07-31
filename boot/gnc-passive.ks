function timeToImpact {
    local v0 is ship:verticalspeed.
    local z0 is ship:altitude.
    local g is 9.81.
    
    local sq is sqrt(2*g*z0 + (v0*v0)).
    
    local t1 is (-v0 + sq)/g.
    local t2 is (-v0 - sq)/g.
    
    clearscreen.
    
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

function geoposImpact {
    parameter vecPos.
    parameter tti.
    

    local ll is body:geoPositionOf(vecPos).
    local lon is ll:lng - (body:angularVel:mag * Constant:RadToDeg * tti).
    
    return latlng(ll:lat, lon).
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

function boostbackParams {
    parameter tgt.
    parameter tti.
    
    local dist is (ship:geoposition:position - tgt:position):mag.
    local optiVel is dist / tti.
    
    local tgtVel is optiVel * heading(tgt:heading, 0):foreVector:normalized.
    local curVel is groundSpeed * heading(getHeading() , 0):foreVector:normalized.
    
    local burnvec is tgtVel - curVel.
    return List(burnVec:normalized, burnVec:mag).
}

global tgt is latlng(28.5117435455322,-19.3019599914551).

until false {

    local tti is timeToImpact().
    
    local impactUT is time + tti.
    local impactVec is positionat(ship, impactUT).
    local ll is geoposImpact(impactVec, tti).
    
    local bb is boostbackParams(tgt, tti).
    
    set drawPos to vecdrawargs( v(0,0,0), ll:ALTITUDEPOSITION(100), green, "Impact", 1, true ).
    set drawBB to vecdrawargs( v(0,0,0), bb[0] * bb[1], red, "Boostback", 1, true ).
    
    print "tti: "+ round(tti, 3)+"s".
    print "Dv:  "+ round(bb[1], 3)+"m/s".
    wait 1.
}