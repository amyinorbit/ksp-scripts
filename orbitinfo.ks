until false {
    clearscreen.
    print "period: "+round(orbit:period/3600, 10)+ "h".
    print "ApA:    "+round(orbit:apoapsis/1000, 4)+"km".
    print "PeA:    "+round(orbit:periapsis/1000, 4)+"km".
    print "Inc:    "+round(orbit:inclination, 2)+"deg".
    wait 0.1.
}