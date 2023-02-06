
# Imports
using FITSIO

# Exports
export SpecData, SpecData1d, SpecData2d, Echellogram, RawSpecData2d, MasterCal2d
export get_spectrograph, get_spec_module
export read_header, read_image, read_spec1d!
export parse_exposure_start_time, parse_itime, parse_object, parse_sky_coord, parse_utdate, parse_airmass, parse_image_num
export get_orders, ordermin, ordermax
export get_λsolution_estimate

# Empty fits header
FITSIO.FITSHeader() = FITSHeader(String[], [], String[])

"""
An abstract type for all Echelle spectra, parametrized by the spectrograph symbol S.
"""
abstract type SpecData{S} end

"""
An abstract type for all 2d spectra with alias `Echellogram`.
"""
abstract type SpecData2d{S} <: SpecData{S} end
const Echellogram{S} = SpecData2d{S}

"""
    get_spectrograph(data::SpecData)
Returns the name of the spectrograph for this SpecData object as a string.
"""
get_spectrograph(::SpecData{S}) where {S} = string(S)

"""
    get_spec_module(::SpecData)
Returns the module for this spectrograph.
"""
function get_spec_module(::SpecData) end

"""
Concrete type for 1D (extracted) spectral data.

# Fields
- `fname::String`: The path + filename.
- `header::FITSHeader`: The fits header.
- `data::Dict{String, Any}` :A Dictionary containing the relevant data products. Default keys are "spec" for the 1D spectrum, "specerr" for the uncertainty, and "λ" for the wavelength grid. These variables can be set or retreived via `data.spec`, `data.specerr`, and `data.λ`

# Constructors
    SpecData1d(fname::String, spectrograph::String, sregion::SpecRegion1d)
"""
struct SpecData1d{S} <: SpecData{S}
    fname::String
    header::FITSHeader
    data::Dict{String, Any}
end

function Base.getproperty(d::SpecData1d, key::Symbol)
    if hasfield(typeof(d), key)
        return getfield(d, key)
    elseif string(key) ∈ keys(d.data)
        return d.data[string(key)]
    else
        @error "Could not get property $key of data SpecData1d object"
    end
end

function Base.setproperty!(d::SpecData1d, key::Symbol, val)
    if key ∈ [:λ, :spec, :specerr]
        d.data[string(key)] = val
    else
        setfield!(d, key, val)
    end
end


function SpecData1d(fname::String, spectrograph::String, sregion::SpecRegion1d)
    data = SpecData1d{Symbol(lowercase(string(spectrograph)))}(fname, FITSHeader(), Dict{String, Any}())
    merge!(data.header, read_header(data))
    read_spec1d!(data, sregion)
    return data
end

"""
Concrete type for a raw echellogram (i.e. not coadded science or calibration image).

# Fields
- `fname::String` The full path+filename.
- `header::FITSHeader` The fits header.

# Constructors
    RawSpecData2d(fname::String, spectrograph::String)
"""
struct RawSpecData2d{S} <: SpecData2d{S}
    fname::String
    header::FITSHeader
end


function RawSpecData2d(fname::String, spectrograph::String)
    data = RawSpecData2d{Symbol(lowercase(spectrograph))}(fname, FITSHeader())
    merge!(data.header, read_header(data))
    return data
end

"""
Concrete type for a master calibration frame which is constructed by combining multiple individual images.

# Fields
- `fname::String`: The filename of the combined image, may not be generated yet.
- `group::Vector{<:SpecData2d}`: The individual `SpecData2d` objects used to generate this frame.

# Constructors
    MasterCal2d(fname::String, group::Vector{<:SpecData2d})
"""
struct MasterCal2d{S} <: SpecData2d{S}
    fname::String
    group::Vector{SpecData2d{S}}
end


function MasterCal2d(fname::String, group::Vector{<:SpecData2d})
    data = MasterCal2d{Symbol(get_spectrograph(group[1]))}(fname, group)
    return data
end

const Echellogram = SpecData2d

# Print
Base.show(io::IO, d::SpecData1d) = print(io, "SpecData1d: $(basename(d.fname))")
Base.show(io::IO, d::RawSpecData2d) = print(io, "RawSpecData2d: $(basename(d.fname))")
Base.show(io::IO, d::MasterCal2d) = print(io, "MasterCal2d: $(basename(d.fname))")

# Useful base methods
Base.:(==)(d1::SpecData, d2::SpecData) = d1.fname == d2.fname
Base.basename(d::SpecData) = basename(d.fname)

"""
Reads in a FITS file header.
"""
function read_header end

"""
Reads in an image.
"""
function read_image end

"""
Reads in the extracted 1D data. By default, this method is called as `read_spec1d!(data::SpecData1d, sregion::SpecRegion1d)`. The fields `data.λ`, `data.spec`, and `data.specerr` should be set here, but only data.spec is required.
"""
function read_spec1d! end

# Parsing header and/or filename info

"""
Parses the integration (exposure) time.
"""
function parse_itime end

"""
Parses the object name.
"""
function parse_object end

"""
Parses the UT date, preferably as a typical UT formatted string: `YYYYMMDD`.
"""
function parse_utdate end

"""
Parses the sky coordinate (may be start/mid/end).
"""
function parse_sky_coord end

"""
Parses the exposure start time.
"""
function parse_exposure_start_time end

"""
Parses the airmass for a given exposure (may be start/mid/end).
"""
function parse_airmass end

"""
Parses the observation number (if relevant) (e.g., img0001.fits -> 1).
"""
function parse_image_num end


# Helpful method to parse info by only passing filename and spectrograph
parse_from_file(f::Function, fname::String, spectrograph::String, t::Type) = f(t(fname, spectrograph))
parse_itime(fname::String, spectrograph::String, t::Type) = parse_from_file(parse_itime, fname, spectrograph, t)
parse_object(fname::String, spectrograph::String, t::Type) = parse_from_file(parse_object, fname, spectrograph, t)
parse_utdate(fname::String, spectrograph::String, t::Type) = parse_from_file(parse_utdate, fname, spectrograph, t)
parse_sky_coord(fname::String, spectrograph::String, t::Type) = parse_from_file(parse_sky_coord, fname, spectrograph, t)
parse_exposure_start_time(fname::String, spectrograph::String, t::Type) = parse_from_file(parse_exposure_start_time, fname, spectrograph, t)
parse_airmass(fname::String, spectrograph::String, t::Type) = parse_from_file(parse_airmass, fname, spectrograph, t)
parse_image_num(fname::String, spectrograph::String, t::Type) = parse_from_file(parse_image_num, fname, spectrograph, t)

# Merge fits headers
function Base.merge!(h1::FITSHeader, h2::FITSHeader)
    for key2 ∈ h2.keys
        if key2 ∉ h1.keys
            h1[key2] = h2[key2]
        end
    end
end

function merge_headers_from_empty!(h1::FITSHeader, h2::FITSHeader)
    h1.comments = h2.comments
    h1.keys = h2.keys
    h1.map = h2.map
    h1.values = h2.values
    nothing
end

"""
Returns the echelle orders as a `Vector` starting from the bottom of the detector.
"""
function get_orders end

"""
    ordermin(data::SpecData)
Returns the minimum echelle order.
"""
ordermin(data::SpecData) = minimum(get_orders(data))

"""
    ordermax(data::SpecData)
Returns the maximum echelle order.
"""
ordermax(data::SpecData) = maximum(get_orders(data))


"""
    get_λsolution_estimate(data::SpecData1d, ::SpecRegion1d)
Returns the approximate wavelength solution for a 1D spectrum. For spectral modeling purposes, this should be within accurate to within 1-2 detector pixels.
"""
get_λsolution_estimate(data::SpecData1d, sregion::SpecRegion1d) = data.λ