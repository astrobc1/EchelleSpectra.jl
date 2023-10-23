export get_exposure_start_time,
       get_itime,
       get_objects,
       get_object,
       get_sky_coord,
       get_utdate,
       get_airmass,
       get_image_num

export get_orders

export read_fitsheader, read_fitsimage, read_fitstable
export read_header, read_image, read_spec1d!

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

read_fitsheader(fname::String; hdu::Int=1) = FITSIO.read_header(fname, hdu)
read_header(data::SpecData; hdu::Int=1) = read_fitsheader(data.fname; hdu)

function read_fitsimage(fname::String; hdu::Int=1, mask_negative::Bool=true)
    image = Float64.(FITSIO.fitsread(fname, hdu))
    if mask_negative
        clamp!(image, 0, Inf)
    end
    return image
end

read_image(data::SpecData2D; hdu::Int=1, mask_negative::Bool=true) = read_fitsimage(data.fname; hdu, mask_negative)
read_image(fname::String, dtype::DataType) = read_image(dtype.name.wrapper(fname, spectrograph))


function read_fitstable(fname::String; hdu::Int=1, column::String, mask_negative::Bool=true)
    d = Float64.(FITSIO.fitsread(fname, hdu, column))
    if mask_negative
        clamp!(d, 0, Inf)
    end
    return d
end

function read_spec1d! end

Base.parse(::Type{Float64}, val::Real) = Float64(val)

function get_orders end


#####################
#### PARSING API ####
#####################


"""
Parses the integration (exposure) time.
"""
function get_itime end


"""
Parses the object name for a single trace.
"""
function get_object end


"""
Parses the object names for multiple traces.
"""
function get_objects end


"""
Parses the UT date.
"""
function get_utdate end


"""
Parses the sky coordinate.
"""
function get_sky_coord end


"""
Parses the exposure start time.
"""
function get_exposure_start_time end


"""
Parses the airmass (may be start, middle, end).
"""
function get_airmass end


"""
Parses the observation number (if relevant) (e.g., img0001.fits -> 1).
"""
function get_image_num end


# Parsing from files
get_itime(fname::String, dtype::DataType) = get_itime(dtype.name.wrapper(fname, string(dtype.parameters[1])))

get_object(fname::String, dtype::DataType) = get_object(dtype.name.wrapper(fname, string(dtype.parameters[1])))

get_objects(fname::String, dtype::DataType) = get_objects(dtype.name.wrapper(fname, string(dtype.parameters[1])))

get_utdate(fname::String, dtype::DataType) = get_utdate(dtype.name.wrapper(fname, string(dtype.parameters[1])))

get_sky_coord(fname::String, dtype::DataType) = get_sky_coord(dtype.name.wrapper(fname, string(dtype.parameters[1])))

get_exposure_start_time(fname::String, dtype::DataType) = get_exposure_start_time(dtype.name.wrapper(fname, string(dtype.parameters[1])))

get_airmass(fname::String, dtype::DataType) = get_airmass(dtype.name.wrapper(fname, string(dtype.parameters[1])))

get_image_num(fname::String, dtype::DataType) = get_image_num(dtype.name.wrapper(fname, string(dtype.parameters[1])))