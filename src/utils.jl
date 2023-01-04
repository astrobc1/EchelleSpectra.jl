using AstroLib

export airmass2alt, alt2airmass, radec2altaz

# Sky coord helpers
airmass2alt(airmass) = π / 2 - asec(airmass)
alt2airmass(alt) = sec(π / 2 - alt)

function radec2altaz(ra, dec, jd, obsname; spherical=true)

    # RA/Dec in degrees
    ra_deg = ra * 180 / π
    dec_deg = dec * 180 / π

    # Alt/Az/HA in degrees
    r = eq2hor(ra_deg, dec_deg, jd, obsname)

    # If Spherical coords
    if spherical
        θ = (90 - r[1]) * π / 180
        ϕ = r[2] * π / 180
        ha_rad = r[3] * π / 180
        return (;θ=θ, ϕ=ϕ, ha=ha_rad)
    else
        # Alt/Az in radians
        alt_rad = r[1] * π / 180
        az_rad = r[2] * π / 180
        ha_rad = r[3] * π / 180
        return (;alt=alt_rad, az=az_rad, ha=ha_rad)
    end
end

radec2altaz(coord, jd, obsname; spherical=true) = radec2altaz(coord.ra, coord.dec, jd, obsname; spherical)