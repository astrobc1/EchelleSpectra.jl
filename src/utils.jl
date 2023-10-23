export radec2altaz, airmass2alt, alt2airmass, gen_image_cube, correct_readmath

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
Convert ra and dec coordinates in degrees to alt/az coordinates for an observatory `obsname` on the date `jd`. If `spherical=true`, the alt/az coordinates are converted to standard spherical coordinates. Returns a `NamedTuple` with fields `alt, az, ha`.
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


function gen_image_cube(data::Vector{<:SpecData2D})
    n_images = length(data)
    image0 = read_image(data[1])
    ny, nx = size(image0)
    image_cube = fill(NaN, (n_images, ny, nx))
    image_cube[1, :, :] .= image0
    if n_images > 1
        for i=2:n_images
            image_cube[i, :, :] .= read_image(data[i])
        end
    end
    return image_cube
end


function correct_readmath(data::Matrix{<:Real}; bzero::Real=0, bscale::Real=1, ndr::Real=1)
    data = (data .- bzero) ./ (bscale * ndr)
    return data
end

function correct_readmath(data::SpecData, image::AbstractArray{<:Real})
    if "BZERO" in keys(data.header)
        bzero = parse(Float64, data.header["BZERO"])
    else
        bzero = 0
    end
    if "BSCALE" in keys(data.header)
        bscale = parse(Float64, data.header["BSCALE"])
    else
        bscale = 1
    end
    if "NDR" in keys(data.header)
        ndr = parse(Float64, data.header["NDR"])
    else
        ndr = 1
    end
    return correct_readmath(image; bzero, bscale, ndr)
end