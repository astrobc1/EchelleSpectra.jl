
export read_fitsimage, read_fitstable
export read_header
export read_image, read_spec1d!
export correct_readmath

export parse_exposure_start_time,
       parse_itime,
       parse_objects,
       parse_object,
       parse_sky_coord,
       parse_utdate,
       parse_airmass,
       parse_image_num

export get_timezone, get_orders, get_dark_current, get_read_noise



####################
#### FITSIO EXT ####
####################


# Empty fits header
FITSIO.FITSHeader() = FITSHeader(String[], [], String[])

# Merge fits headers
function Base.merge!(h1::FITSHeader, h2::FITSHeader)
    for key2 ∈ h2.keys
        if key2 ∉ h1.keys
            h1[key2] = h2[key2]
        end
    end
end

"""
    read_header(fname::String, hdu::Int=1)
    read_header(data::SpecData, hdu::Int=1)
Reads in a FITS file header.
"""
function read_header(fname::String, hdu::Int=1)
    f = FITS(fname)
    h = FITSIO.read_header(f[hdu])
    close(f)
    return h
end


#####################
#### API METHODS ####
#####################

read_header(data::SpecData; hdu::Int=1) = read_header(data.fname, hdu)


"""
    read_fitsimage(fname::String, hdu::Int; mask_negative=true)
Reads in an image HDU from filename `fname` and HDU `hdu`, then casts to `Float64`. If `mask_negative=true`, negative values are set to NaN.
"""
function read_fitsimage(fname::String; hdu::Int=1, mask_negative::Bool=true)
    f = FITS(fname)
    data = read(f[hdu])
    close(f)
    data = Float64.(data)
    if mask_negative
        bad = findall(data .< 0)
        data[bad] .= NaN
    end
    return data
end


"""
    read_fitstable(fname::String, hdu::Int, label::String; mask_negative=true)
Reads in an FITS table extension from filename `fname`, HDU `hdu`, and column name `label`.  If `mask_negative=true`, negative values are set to NaN.
"""
function read_fitstable(fname::String; hdu::Int=1, label::String, mask_negative::Bool=true)
    f = FITS(fname)
    data = read(f[hdu], label)
    close(f)
    data = Float64.(data)
    if mask_negative
        bad = findall(data .< 0)
        data[bad] .= NaN
    end
    return data
end


"""
    read_image(data::SpecData2D, hdu::Int)
    read_image(fname::String, dtype::Type)
Read in a FITS image extension in `hdu` for `data`.
"""
read_image(data::SpecData2D, hdu::Int=1; kwargs...) = read_fitsimage(data.fname, hdu; kwargs...)
function read_image(fname::String, dtype::DataType)
    data = dtype.name.wrapper(fname, spectrograph)
    return read_image(data)
end



"""
    read_spec1d!(data::SpecData1D, ::SpecRegion1D)
Reads in an extracted 1D spectrum (λ, spectrum, spectrum errors, etc.) and stores data products in the dictionary `data.data`. Must be implemented for a given spectrograph.
"""
read_spec1d!(data::SpecData1D, ::SpecRegion1D) = error("Must implement method `read_spec1d!(data::SpecData1D{:spectrograph}, sregion::SpecRegion1D)` for $(get_spectrograph(data))!")

"""
    correct_readmath(data::SpecData, image::AbstractArray{<:Real})
    correct_readmath(data::AbstractArray{<:Real}; bzero::Real, bscale::Real)
Corrects bzero and bscale.
"""
function correct_readmath(data::AbstractArray{<:Real}; bzero::Real=0, bscale::Real=1, ndr::Real=1)
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

Base.parse(::Type{Float64}, val::Real) = Float64(val)

#####################
#### PARSING API ####
#####################


"""
Parses the integration (exposure) time.
"""
function parse_itime end


"""
Parses the object name for a single trace.
"""
function parse_object end


"""
Parses the object names for multiple traces.
"""
function parse_objects end


"""
Parses the UT date.
"""
function parse_utdate end


"""
Parses the sky coordinate.
"""
function parse_sky_coord end


"""
Parses the exposure start time.
"""
function parse_exposure_start_time end


"""
Parses the airmass (may be start, middle, end).
"""
function parse_airmass end


"""
Parses the observation number (if relevant) (e.g., img0001.fits -> 1).
"""
function parse_image_num end


# Parsing from files
parse_itime(fname::String, dtype::DataType) = parse_itime(dtype.name.wrapper(fname, string(dtype.parameters[1])))
parse_object(fname::String, dtype::DataType) = parse_object(dtype.name.wrapper(fname), string(dtype.parameters[1]))
parse_objects(fname::String, dtype::DataType) = parse_objects(dtype.name.wrapper(fname), string(dtype.parameters[1]))
parse_utdate(fname::String, dtype::DataType) = parse_utdate(dtype.name.wrapper(fname), string(dtype.parameters[1]))
parse_sky_coord(fname::String, dtype::DataType) = parse_sky_coord(dtype.name.wrapper(fname), string(dtype.parameters[1]))
parse_exposure_start_time(fname::String, dtype::DataType) = parse_exposure_start_time(dtype.name.wrapper(fname), string(dtype.parameters[1]))
parse_airmass(fname::String, dtype::DataType) = parse_airmass(dtype.name.wrapper(fname, string(dtype.parameters[1])))
parse_image_num(fname::String, dtype::DataType) = parse_image_num(dtype.name.wrapper(fname), string(dtype.parameters[1]))


"""
    Gets the utc offset.
"""
function get_timezone end


"""
    Get all echelle orders.
"""
function get_orders end


"""
    Get the dark current.
"""
function get_dark_current end


"""
    Get the read noise.
"""
function get_read_noise end