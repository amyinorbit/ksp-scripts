declare function limits {
    declare parameter value.
    return min(max(value, 0), 1.0).
}

global stage_thrust is 0.
declare function updateThrust {
    local eng is list().
    list engines in eng.
    set stage_thrust to 0.
    for e in eng {
        if e:ignition {
            local th is e:availablethrustat(0).
            set stage_thrust to stage_thrust + th.
        }
    }
}

function zeroRateAlt {
    declare parameter thr.
    
    local currentThr is stage_thrust * thr.
    local accel is (9.81 - (currentThr / ship:mass)).
    local t is abs(ship:verticalspeed / accel).
    
    // x(t) = x(0) + v*t + 1/2 * a * t^2
    
    local distance is abs(ship:verticalspeed*t) + (0.5 * accel * (t^2)).
    
    clearscreen.
    print("stopping time: "+t).
    print("zero velocity alt: "+ (alt:radar-(distance+28))).
    
    return (alt:radar - distance) - 28.
}

wait 20.
wait until ship:verticalspeed < 0.

local throttle_pid to pidloop(.05, 0, 0, -0.2, 0.2).
set throttle_pid:setpoint to 0.

wait until altitude < 4000.
local trig is 10.
until trig < 0 {
    set trig to zeroRateAlt(0.8).
    wait 0.1.
}

until status = "LANDED" or verticalspeed > 0 {
    lock throttle to limits(0.8 + throttle_pid:update(time:seconds, zeroRateAlt(0.8))).
    wait 0.1.
}
unlock throttle.
set throttle to 0.