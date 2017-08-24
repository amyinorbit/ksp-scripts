// Powered Explicit Guidance
// Second Stage closed-loop guidance algorithm
copypath("0:/az", "").
run once az.

declare global peg_start to 0.

declare global peg_boosters to 0.
declare global peg_launchcap to 1.0.
declare global peg_major to 0.5.
declare global peg_eps to 16.
declare global peg_maxqdip to 0.9.
declare global holddown to 1.
declare global peg_gcap to 2.2.
declare global peg_meco_ap to -1.
declare global peg_vector_offset to 0.
declare global peg_vector_loffset to 0.

declare global g_thr to 0.
declare global g_steer to ship:up.

declare global fairing to true.
declare global prefairing to false.

declare global tgt_r to 200000.
declare global tgt_vy to 0.
declare global tgt_vx to 0.
declare global tgt_pe to 0.
declare global tgt_ap to 0.
declare global tgt_inc to 0.
declare global tgt_h to 0.

declare global peg_gimbal to 0.

declare global radius to orbit:body:radius.
declare global mu to orbit:body:mu.

// State variables, used by the algorithm to know where it's at.
// We try to be realistic and use actual acceleration, so we need
// at least one acceleration sensor on the second stage.
declare global s_vy to 0.
declare global s_vx to 0.
declare global s_acc to 0.
declare global s_ve to 0.
declare global s_r to 0.
declare global s_met to missiontime.
declare global s_eng to list().
declare global s_T to 180.
declare global s_pitch to 0.


declare global e_thr to 0.

// Print data to the console
declare global vis_title to "Ascent Guidance".
declare global vis_msg to "".
declare global vis_dbg to "".

declare function debug {
    declare parameter value.
    set vis_dbg to value.
}

declare function peg_msg {
    declare parameter msg.
    set vis_msg to msg.
}

declare function peg_throttle_cap {
    declare parameter gees to 2.5.
    local th is (gees * 9.81) / (e_thr/ship:mass).
    return min(1.0, max(0.5, th)).
}

declare function peg_wrap_heading {
    declare parameter hdg.
    return mod(hdf + 360).
}

declare function peg_update_engines {
    list engines in s_eng.
    local e_isp is 0.
    set e_thr to 0.
    for e in s_eng {
        if e:ignition {
            local th is e:availablethrustat(0).
            set e_isp to e_isp + (e:visp*th).
            set e_thr to e_thr + th.
        }
    }
    if(e_thr > 0) {
        set s_ve to 9.80665*(e_isp/e_thr).
    }
}

declare function peg_vis {
    clearscreen.
    print vis_title + "T+"+round(s_met, 0)+"s".
    print " ".
    print vis_msg.
    print " ".
    print "SECO MET: "+round(s_met+s_T, 0)+"s".
    print "GNC State:".
    print "  ApA: "+round(orbit:apoapsis/1000, 2)+"/"+round(tgt_ap/1000, 2)+"km".
    print "  PeA: "+round(orbit:periapsis/1000, 2)+"/"+round(tgt_pe/1000, 2)+"km".
    print "  Inc: "+round(orbit:inclination, 2)+"/"+round(tgt_inc, 2)+"deg".
}

// Return a vector some angle above (or below) prograde.
declare function prograde_pitch {
    declare parameter p.
    local h is vcrs(ship:up:vector, ship:velocity:orbit):normalized.
    set vecH:vec to h*100.
    local v is -1 * vcrs(h, ship:up:vector):normalized.
    set vecV:vec to v*100.
    return angleaxis(p, v) * ship:prograde.
}

declare function mission_elapsed_time {
    return missiontime - peg_start.
}


// Prepare stuff for the PEG algorithm to use later
// Must be ran before launch, since some stuff depends on launch location
// (at the moment, launch azimuth).

declare function peg_init {
    declare parameter pe.
    declare parameter ap.
    declare parameter u.
    declare parameter inc.
    
    lock s_met to missiontime.
    
    set tgt_pe to pe*1000.
    set tgt_ap to ap*1000.
    set tgt_inc to inc.

    set ra to radius+(ap*1000).
    set rp to radius+(pe*1000).

    local a is (ra+rp)/2.
    local e is (ra-rp)/(ra+rp).
    local vp is sqrt((2*mu*ra)/(rp*2*a)).
    local rc is (a*(1-e^2))/(1+e*cos(u)).
    local vc is sqrt((vp^2) + 2*mu*((1/rc)-(1/rp))).
    local uc is 90 - arcsin((rp*vp)/(rc*vc)).
    
    set tgt_r to rc.
    set tgt_vy to vc*sin(uc).
    set tgt_vx to vc*cos(uc).
    
    set tgt_h to vcrs(v(tgt_r, 0, 0), v(tgt_vy, tgt_vx, 0)):mag.
    
    peg_update_engines().
}

declare function read_imu {
    set s_r to ship:orbit:body:distance.
    //set s_acc to ship:sensors:acc:mag.
    set s_acc to e_thr/ship:mass.
    set s_vy to ship:verticalspeed.
    set s_vx to sqrt(ship:velocity:orbit:sqrmagnitude - ship:verticalspeed^2).
    
}

declare function peg_hdg {
    declare parameter compass.
    declare parameter pitch.
    return lookdirup(heading(compass, pitch):vector, -ship:up:vector).
}

declare function peg_vec {
    declare parameter vec.
    return lookdirup(vec, -ship:up:vector).
}

declare function peg_dir {
    declare parameter dir.
    return lookdirup(dir:vector, -ship:up:vector).
}

declare function peg_gimbal_pitch {
    local p is 0.
    if s_eng:length = 0 {
        return 0.
    }
    for e in s_eng {
        if e:ignition {
            set p to p + (e:gimbal:pitchangle * e:gimbal:range * (e:gimbal:limit/100.0)).
        }
    }
    set p to p / s_eng:length.
    set peg_gimbal to ((0.8 * peg_gimbal) + (0.2 * p)).
    return peg_gimbal.
}

// Estimate, returns A and B coefficient for guidance
declare function peg_solve {
    declare parameter T.
    declare parameter tau.

    local b0 is -s_ve * ln(1 - (T/tau)).
    local b1 is (b0*tau) - (s_ve*T).
    local c0 is b0*T - b1.
    local c1 is (c0*tau) - (s_ve * T^2)/2.
    
    local z0 is tgt_vy - s_vy.
    local z1 is (tgt_r - s_r) - s_vy*T.
    
    local d is (b0*c1 - b1*c0).
    
    local B is (z1/c0 - z0/b0) / (c1/c0 - b1/b0).
    local A is (z0 - b1*B) / b0.
    
    return list(A, B).
}

declare function peg_cycle {
    declare parameter oldA.
    declare parameter oldB.
    declare parameter oldT.
    declare parameter delta.
    
    
    local A is 0.
    local B is 0.
    local C is 0.
    local T is 0.
    local tau is s_ve/s_acc.
    
    if oldA = 0 and oldB = 0 {
        local ab is peg_solve(oldT, tau).
        set oldA to ab[0].
        set oldB to ab[1].
    }
    
    local Tm is oldT - delta.
    
    local h0 is vcrs(v(s_r, 0, 0), v(s_vy, s_vx, 0)):mag.
    local dh is tgt_h - h0.
    
    set C to (mu/s_r^2 - s_vx^2/s_r)/s_acc.
    local CT is (mu/tgt_r^2 - tgt_vx^2/tgt_r) / (s_acc / (1-(oldT/tau))).
    
    local frT is oldA + oldB*oldT + CT.
    local fr is oldA + C.
    local frdot is (frT-fr)/oldT.
    
    local ft is 1 - (fr^2)/2.
    local ftdot is -fr*frdot.
    local ftdd is -(frdot^2)/2.
    
    local mean_r is (tgt_r + s_r)/2.
    local dv is (dh/mean_r) + (s_ve*Tm*(ftdot+ftdd*tau)) + ((ftdd*s_ve*Tm^2)/2).
    set dv to dv / (ft + ftdot*tau + ftdd*(tau^2)).
    set T to tau*(1 - constant:e ^ (-dv/s_ve)).
    debug("Gimbal: "+peg_gimbal_pitch).
    
    if(T >= peg_eps) {
        local ab is peg_solve(oldT, tau).
        set A to ab[0].
        set B to ab[1].
    } else {
        peg_msg("terminal guidance enable").
        set A to oldA.
        set B to oldB.
    }
    return list(A, B, C, T).
}


//////////// PEG Guidance states ////////////
// At the moment, we only handle two-stage rockets
// (not like we've got anything else anyway)

// Main wrapper function
declare function peg_ascent {
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
    set g_steer to heading(0, 90+peg_vector_loffset).
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
    
    peg_boost(kick_start, kick_end, kick, hdg).
    peg_stage().
    peg_closedloop().
}

declare function peg_atmo_throttle {
    return 1.
}


function atmo_getHeading {
    return Body:GeoPositionOf(Ship:Position +Ship:Velocity:Surface):Heading.
}

function atmo_getPitch {
    return 90 - VectorAngle(Up:ForeVector, Ship:Velocity:Surface).
}

function wrap_heading {
    declare parameter hdg.
    if hdg > 360 {
        return hdg - 360.
    }
    if hdg < 0 {
        return hdg + 360.
    }
    return hdg.
}

declare function angle_diff {
    declare parameter a1.
    declare parameter a2.
    
    local phi is MOD(a1 - a2, 360).
    if phi > 180 {
        return phi - 360.
    }
    if phi < -180 {
        return phi + 360.
    }
    return phi.
}

declare function peg_cappedAZ {
    declare parameter i.
    declare parameter vx.
    declare parameter cap.
    
    local opt_heading is inst_az(i, vx).
    local cur_heading is atmo_getHeading().
    
    local diff is angle_diff(opt_heading, cur_heading).
    set diff to Min(Max(diff, -cap), cap).
    
    return wrap_heading(cur_heading + diff).
}


declare function peg_closedboost {
    local mult is 1 - (ship:q * 250).
    return heading(peg_cappedAZ(tgt_inc, tgt_vx, 15*mult), atmo_getPitch()):foreVector.
}

declare function peg_pitch_kick {
    declare parameter kick_start.
    declare parameter kick_end.
    declare parameter kick.
    declare parameter hdg.
    
    set t to (s_met - kick_start)/(kick_end-kick_start).
    set angle to t*kick.
    if(hdg < 0) {
        return peg_hdg(inst_az(tgt_inc, tgt_vx), 90 - angle).
    } else {
        return peg_hdg(hdg, 90 - angle).
    }
}

// Boost phase, runs open-loop guidance until first stage is empty.
declare function peg_boost {
    declare parameter kick_start.
    declare parameter kick_end.
    declare parameter kick.
    declare parameter hdg.
    
    set tgt_meco_ap to 0.95*(tgt_r-radius).
    if(peg_meco_ap > 0) {
        set tgt_meco_ap to peg_meco_ap * 1000.
    }
    peg_msg("launch command").
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
    
    when ship:velocity:surface:mag > 290 then {
        set g_thr to peg_maxqdip.
    }
    
    when ship:velocity:surface:mag > 360 then {
        set g_thr to 1.0.
    }
    
    when s_met > 70 then {
        until peg_boosters = 0 {
            stage.
            set peg_boosters to peg_boosters -1.
            wait 1.
        }
    }
    
    lock g_steer to peg_pitch_kick(kick_start, kick_end, kick, hdg).
    
    until s_met > kick_end {
        read_imu().
        peg_vis().
        wait 0.5.
    }
    
    peg_msg("aoa-bound flight").
    lock g_steer to peg_vec(ship:velocity:surface).
    
    when ship:altitude > 15000 then {
        lock g_thr to peg_throttle_cap(peg_gcap).
    }
    
    if(prefairing = true) {
        when(ship:q < 0.001) then {
            stage.
        }
    }
    
    when ship:q < 0.004 then {
        peg_msg("Q-alpha steering").
        lock g_steer to peg_vec(peg_closedboost()).
    }
    
    until ship:altitude > 40000 and (stage:liquidfuel < 20 or apoapsis > tgt_meco_ap) {
        read_imu().
        peg_vis().
        wait 0.5.
    }
    if stage:liquidfuel < 20 {
        peg_msg("BECO - Low Fuel").
    } else {
        peg_msg("BECO").
    }
    set g_thr to 0.
    unlock steering.
    set ship:control:neutralize to true.
    wait 3.
    set ag5 to true.
}

// Staging phase. handles staging, ullage, second stage ignition.
// Follows prograde vector for 10 seconds (enough to ignite, stabilise
// thrust and possibly separate fairing).
// After ten seconds, the guidance is handed over to PEG.
declare function peg_stage {
    stage.
    read_imu().
    peg_msg("Stage 1-2 Separation").
    
    // Settle propellant with RCS
    rcs on.
    set ship:control:fore to 1.0.
    wait 5.
    
    // Start Engine
    peg_msg("second stage MES").
    stage.
    set g_thr to 1.
    local ign_time is missiontime.
    set ship:control:neutralize to true.
    lock steering to g_steer.
    lock g_steer to peg_vec(peg_closedboost()).
    
    until (missiontime > ign_time+3 and ship:q < 0.001) {
        read_imu().
        peg_vis().
        wait 0.5.
    }
    // ditch fairing
    if(fairing) {
        stage.
    }
    wait 1.
}

// Powered Explicit Guidance phase.
// Converges guidance, and then takes over second stage flight through
// closed loop control. SECO is triggered when T is reached.
declare function peg_closedloop {
    peg_update_engines().
    peg_msg("PEG convergence enable").
    
    local last is s_met.
    local A is 0.
    local B is 0.
    local C is 0.
    local converged is -5.
    local delta is 0.
    
    local stabiliseSECO is 0.
    
    read_imu().
    peg_cycle(A, B, s_T, 0).
    wait 0.
    
    // run a first loop of PEG
    until false {
        
        read_imu().
        set delta to s_met - last.
        
        if(delta >= peg_major) {
            peg_vis().
            
            local g is peg_cycle(A, B, s_T, peg_major).
            if abs( (s_T-2*peg_major)/g[3] - 1 ) < 2/100 {
                if converged < 0 {
                    set converged to converged+1.
                } else if converged = 0 {
                    set converged to 1.
                    peg_msg("closed loop enable").
                }
            }

            set A to g[0].
            set B to g[1].
            set C to g[2].
            set s_T to g[3].
            set delta to 0.
            
            set last to s_met.
        }

        set s_pitch to (A - B*delta + C).
        set s_pitch to max(-1, min(s_pitch, 1)).
        set s_pitch to arcsin(s_pitch).
        
        if converged = 1 {
            if(s_T - delta < 0.1) {
                break.
            } else if s_T - delta < 1 {
                if stabiliseSECO = 0 {
                    set g_steer to heading(inst_az(tgt_inc, tgt_vx), s_pitch).
                    set stabiliseSECO to 1.
                }
            } else {
                set g_steer to heading(inst_az(tgt_inc, tgt_vx), s_pitch + peg_vector_offset).
            }
        }
        wait 0.
    }
    peg_vis().
    
    set g_thr to 0.
    unlock throttle.
    set ship:control:pilotmainthrottle to 0.
    
    peg_msg("SECO").
    for e in s_eng {
        if e:ignition and e:allowshutdown {
            e:shutdown.
        }
    }
    wait 5.
    unlock steering.
    unlock g_steer.
}