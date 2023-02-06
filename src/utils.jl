using AstroLib, SkyCoords

export airmass2alt, alt2airmass, radec2altaz


"""
    airmass2alt(airmass::Real)
Convert airmass to altitude in radians.
"""
airmass2alt(airmass::Real) = π / 2 - asec(airmass)

"""
    alt2airmass(alt::Number)
Convert altitude in radians to airmass.
"""
alt2airmass(alt::Real) = sec(π / 2 - alt)

"""
    radec2altaz(ra::Real, dec::Real, jd::Real, obsname::String; spherical::Bool=true)
    radec2altaz(coord::ICRSCoords, jd::Real, obsname::String; spherical::Bool=true)
Convert ra and dec coordinates in degrees to alt/az coordinates for an observatory `obsname` on the date `jd`. If `spherical=true`, the alt/az coordinates are converted to standard spherical coordinates.
"""
function radec2altaz(ra::Real, dec::Real, jd::Real, obsname::String; spherical::Bool=true)

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

radec2altaz(coord::ICRSCoords, jd::Real, obsname::String; spherical::Bool=true) = radec2altaz(coord.ra, coord.dec, jd, obsname; spherical)