
declare function qalpha {
    local mult is 4 * (1 - (ship:altitude / 70000)).
    set mult to min(max(mult, 0), 4).
    local aoa is VectorAngle(ship:velocity:surface, ship:facing:foreVector).
    return ship:q * aoa * mult.
}

declare function abortFlight {
    set abort to true.
    wait 6.
    wait until ship:verticalSpeed < 20.
    until stage:ready = false {
        stage.
        wait 3.
    }
}

until ag5 {
    clearscreen.
    print("a-alpha: " + round(qalpha(), 2) + "/0.8").
    if qalpha() > 0.8 {
        abortFlight().
        local end is 1/0.
    }
    wait 0.05.
}
