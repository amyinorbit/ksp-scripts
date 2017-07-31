wait 5.
copypath("0:/peg_lib", "").
run once peg_lib.

// Boost phase, runs open-loop guidance until first stage is empty.
declare function halfstage_boost {
    declare parameter kick_start.
    declare parameter kick_end.
    declare parameter kick.
    declare parameter hdg.
    
    peg_msg("HALF-STAGE launch command").
    set g_thr to peg_launchcap.
    set peg_start to missiontime.
    lock s_met to mission_elapsed_time().
    stage.
    until (ship:altitude > 100) and (s_met > kick_start) {
        read_imu().
        peg_vis().
        wait 0.5.
    }
    
    peg_msg("pitch kick").
    set angle to 0.
    set t to 0.
    
    until s_met > kick_end {
        set t to (s_met - kick_start)/(kick_end-kick_start).
        set angle to t*kick.
        if(hdg < 0) {
            set g_steer to heading(inst_az(tgt_inc, tgt_vx), 90 - angle).
        } else {
            set g_steer to heading(hdg, 90 - angle).
        }
        
        read_imu().
        peg_vis().
        wait 0.5.
    }
    peg_msg("aoa-bound flight").
    lock g_steer to ship:velocity:surface.
    
    until s_met > 130 {
        read_imu().
        peg_vis().
        wait 0.5.
    }
    stage.
    until ship:q < 0.01 {
        read_imu().
        peg_vis().
        wait 0.5.
    }
}

declare function halfstage_ascent {
    declare parameter pe.
    declare parameter ap.
    declare parameter u.
    declare parameter inc.
    declare parameter kick_start.
    declare parameter kick_end.
    declare parameter kick.
    declare parameter hdg to -1.
    
    peg_init(pe, ap, u, inc).
    read_imu().
    peg_msg("launch sequence enable").

    // basic stuff that stays true until the end of ascent guidance
    set g_thr to 0.
    set g_steer to heading(0, 90).
    lock throttle to g_thr.
    lock steering to g_steer.
    rcs off.
    sas off.
    
    peg_msg("guidance enable").
    wait 2.
    peg_msg("ignition command").
    set g_thr to 1.
    stage.
    peg_update_engines().
    wait holddown.
    
    halfstage_boost(kick_start, kick_end, kick, hdg).
    peg_closedloop().
}



declare parameter pe to 140.
declare parameter ap to 230.
declare parameter inc to -35.
declare parameter u to 0.
declare parameter kick_start is 20.
declare parameter kick_end is 60.
declare parameter kick is 12.
declare parameter burn is 200.
declare parameter hdg to -1.

set peg_boosters to 0.
set peg_meco_ap to 130.
set peg_eps to 6.
set peg_gcap to 3.0.
set peg_maxqdip to 1.0.
set fairing to false.
set s_T to burn.

halfstage_ascent(pe, ap, u, inc, kick_start, kick_end, kick, hdg).