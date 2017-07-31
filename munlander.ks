declare function neutral {
    return ship:mass*9.81*0.2 / ship:availablethrust.
}

declare function main {
    local throttle_pid to pidloop(.05, 0, 0.01, 0, 1).
    lock steering to ship:srfretrograde.
    
    set throttle to 0.
    wait until alt:radar < 8000.
    print("Engaging braking burn").
    lock throttle to 1.
    wait until ship:velocity:surface:mag < 50.
    set throttle_pid:setpoint to -50.
    lock throttle to throttle_pid:update(time:seconds, -ship:velocity:surface:mag).
    wait until alt:radar < 300.
    print("Radar alt < 300, engaging final descent!").
    set throttle_pid:setpoint to -3.
    lock throttle to throttle_pid:update(time:seconds, verticalspeed).


    wait until alt:radar < 3.
    print("HERE COMES THE DROP!").
    unlock throttle.
    unlock steering.
    set throttle to 0.
}

main().




