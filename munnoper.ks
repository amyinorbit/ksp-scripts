copypath("0:/exec_lib", "").
run once exec_lib.

global g_start is 0.

function pitch {
    parameter from.
    parameter to.
    parameter t.
    
    return from + t * (to-from).
}

function met {
    return missiontime - g_start.
}

declare function mun_main2 {
    set g_start to missiontime.
    lock throttle to 0.
    
    lock throttle to 1.
    wait 0.5.
    lock throttle to 0.
    lock steering to heading(90, 20).
    wait 10.
    lock throttle to 1.
    wait 15.
    lock throttle to 0.
    wait 1.
    stage.
    lock throttle to 1.
    lock steering to heading(90, 0).
    wait until apoapsis > 50000.
    lock throttle to 0.
    lock steering to ship:prograde.
    wait 120.
    exec(0.1).
    //wait 120.
    //exec(0.1).
    wait 3600 * 5.
    wait until altitude < 100000.
    lock steering to ship:srfretrograde.
    stage.
    wait until altitude < 65000.
    unlock steering.
    wait until ship:velocity:surface:mag < 150 and alt:radar < 2000.
    stage.
}


declare function mun_main {
    set g_start to missiontime.
    lock throttle to 0.
    
    stage.
    lock throttle to 1.
    wait 1.
    lock steering to heading(90, 90 - pitch(0, 45, (met() - 1)/3.0)).
    wait 3.
    lock steering to heading(90, 90 - pitch(45, 90, (met() - 4)/15)).
    wait 15.
    lock steering to heading(90, 0).
    wait until apoapsis > 50000.
    lock throttle to 0.
    lock steering to ship:prograde.
    wait 120.
    exec(0.1).
    //wait 120.
    //exec(0.1).
    wait 3600 * 5.
    wait until altitude < 100000.
    lock steering to ship:srfretrograde.
    wait 20.
    stage.
    wait until altitude < 65000.
    unlock steering.
    wait until ship:velocity:surface:mag < 150 and alt:radar < 2000.
    stage.
    
}
