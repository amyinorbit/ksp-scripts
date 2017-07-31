set burn_vector to ship:prograde.

set r_ap to ship:apoapsis + orbit:body:radius.
set act_vx to sqrt(orbit:body:mu * ((2/r_ap)-(1/ship:obt:semimajoraxis))).
set tgt_vx to orbit:body:radius * sqrt(9.8/r_ap).

set tgt_dv to tgt_vx - act_vx.
print "Circularization Burn DV: "+round(tgt_dv, 2).