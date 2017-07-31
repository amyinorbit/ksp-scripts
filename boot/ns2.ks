declare function neutral {
    return ship:mass*9.81 / ship:availablethrust.
}

declare function limits {
    declare parameter value.
    return min(max(value, 0), 1.0).
}

declare function steer_iip {
    declare parameter tgt.
    declare parameter xp.
    declare parameter yp.
    
    //declare parameter pid.

    local delta is ((ship:verticalspeed^2)+(2*9.81*ship:altitude)).
    local tti is 0.
    clearscreen.
    if delta > 0 {
        local s1 is (-verticalspeed + sqrt(delta))/(-2*9.81).
        local s2 is (-verticalspeed - sqrt(delta))/(-2*9.81).
        set tti to max(s1, s2).
    }
    else if delta = 0 {
        local s is (-verticalspeed)/(-2*9.81).
        set tti to s.
    }
    else {
        print("no solution found").
        local err is 1/0.
    }
    
    local x_axis is heading(90, 0):forevector.
    local y_axis is heading(0, 0):forevector.
    
    local tx is vdot(x_axis, tgt:position).
    local ty is vdot(y_axis, tgt:position).
    
    local iip is ship:position + (tti * ship:velocity:surface).
    
    local x is vdot(x_axis, iip).
    local y is vdot(x_axis, iip).
    
    print("err_x: "+round(tx-x, 4)).
    print("err_y: "+round(ty-y, 4)).
    
    local distance is sqrt(((tx-x)^2)+((ty-y)^2)).
    
    print("dist:  "+round(distance, 4)).
    
    local hdg is arctan2(tx-x, ty-y).
    if hdg < 0 {
        set hdg to 360+hdg.
    }
    print("hdg:   "+hdg).
    local Tx is xp:update(time:seconds, tx-x).
    local Ty is yp:update(time:seconds, ty-y).
    
    return (ship:up + R(-Ty, -Tx, 0)):forevector.
}

declare function steer_terminal {
    declare parameter tgt.
    declare parameter vxp.
    declare parameter vyp.
    
    //time_to_iip(tgt).
    
    local x_axis is heading(90, 0):forevector.
    local y_axis is heading(0, 0):forevector.
    
    local vx is vdot(x_axis, ship:velocity:surface).
    local vy is vdot(y_axis, ship:velocity:surface).
    
    local x is vdot(x_axis, tgt:position).
    local y is vdot(y_axis, tgt:position).
    
    set vxp:setpoint to 0.
    set vyp:setpoint to 0.
    
    local Tx is vxp:update(time:seconds, vx).
    local Ty is vyp:update(time:seconds, vy).
    
    return (ship:up + R(-Ty, -Tx, 0)):forevector.
}

declare function steer_ldg {
    declare parameter tgt.
    declare parameter xp.
    declare parameter vxp.
    declare parameter yp.
    declare parameter vyp.
    
    //time_to_iip(tgt).
    
    local x_axis is heading(90, 0):forevector.
    local y_axis is heading(0, 0):forevector.
    
    local vx is vdot(x_axis, ship:velocity:surface).
    local vy is vdot(y_axis, ship:velocity:surface).
    
    local x is vdot(x_axis, tgt:position).
    local y is vdot(y_axis, tgt:position).
    
    local xpout is -xp:update(time:seconds, x).
    local ypout is -yp:update(time:seconds, y).
    
    set vxp:setpoint to xpout.
    set vyp:setpoint to ypout.
    
    local Tx is vxp:update(time:seconds, vx).
    local Ty is vyp:update(time:seconds, vy).
    
    return (ship:up + R(-Ty, -Tx, 0)):forevector.
}

wait 2.

// The Dome
//local tgt is latlng(28.5954341888428,-19.7294597625732).
// Top of the bridge
//local tgt is latlng(28.6003589630127,-19.724515914917).
// top of the SPH.
//local tgt is latlng(28.6213545684814,-19.7176916046143).
// The parking spot.
//local tgt is latlng(latitude-0.009, longitude-0.047).
// The helipad.
//local tgt is latlng(28.5993545684814,-19.7226916046143).
// On the pad
//local tgt is latlng(28.6083545684814, -19.6757316589355).
local tgt is latlng(latitude+0.0001, longitude+0.0008).

local aerox_pid is pidloop(.2, 0, 0.75, -10, 10).
local aeroy_pid is pidloop(.2, 0, 0.75, -10, 10).
set aerox_pid:setpoint to 0.
set aeroy_pid:setpoint to 0.

local throttle_pid to pidloop(.05, 0, 0.01, -1, 1).


// Landing PIDs
local landing_xpid is pidloop(0.5, 0, 1.15, -10, 10).
local landing_xvpid is pidloop(1.8, 0, 0, -10, 10).
set landing_xpid:setpoint to 0.

local landing_ypid is pidloop(0.5, 0, 1.15, -10, 10).
local landing_yvpid is pidloop(1.8, 0, 0, -10, 10).
set landing_ypid:setpoint to 0.

clearscreen.
local tset is 0.
lock throttle to tset.


HUDTEXT("Launch Enable", 10, 1, 30, yellow, false).
wait 2.
HUDTEXT("Ignition", 10, 1, 30, yellow, false).
set tset to 1.
stage.
wait 2.
HUDTEXT("Launch", 10, 1, 30, yellow, false).
lock steering to heading(80, 89.6).
stage.

wait until apoapsis > 80000.
HUDTEXT("Main Engine Cutoff", 10, 1, 30, yellow, false).
unlock steering.
set tset to 0.

wait until altitude > 50000.
HUDTEXT("Crew Capsule Separation", 10, 1, 30, yellow, false).
rcs on.
stage.
wait 5.
lock steering to heading(90, 90).


wait until verticalspeed < -100.
HUDTEXT("Descent Mode Enable", 10, 1, 30, yellow, false).
lock steering to heading(90, 90).

wait until altitude < 65000.
lock steering to steer_iip(tgt, aerox_pid, aeroy_pid).

wait until altitude < 7000.
HUDTEXT("Aerodynamic Brakes Deploy", 10, 1, 30, yellow, false).
set AG1 to true.

wait until alt:radar < 900.
set throttle_pid:setpoint to -2.
HUDTEXT("Landing Burn Ignition", 10, 1, 30, yellow, false).
lock steering to ship:srfretrograde.
lock throttle to limits(neutral() + throttle_pid:update(time:seconds, verticalspeed)).

wait until verticalspeed > -50.
HUDTEXT("Terminal Guidance Enable", 10, 1, 30, yellow, false).
lock steering to steer_ldg(tgt, landing_xpid, landing_xvpid, landing_ypid, landing_yvpid).

wait until verticalspeed > -20.
HUDTEXT("Landing Gear Deploy", 10, 1, 30, yellow, false).
set gear to true.

wait until alt:radar < 30.
HUDTEXT("Landing Mode Enable", 10, 1, 30, yellow, false).
lock steering to steer_terminal(tgt, landing_xvpid, landing_yvpid).

wait until status = "LANDED".
HUDTEXT("Engine Cutoff", 10, 1, 30, yellow, false).

unlock throttle.
set throttle to 0.
unlock steering.

