
# Imports
using FITSIO

# Exports
export SpecData, SpecData1d, SpecData2d, SpecData1dor2d, RawSpecData2d, MasterCal2d, SpecData1dor2d
export get_spectrograph, get_spec_module
export read_header, read_image, read_spec1d!
export parse_exposure_start_time, parse_itime, parse_object, parse_sky_coord, parse_utdate, parse_airmass, parse_image_num
export get_orders, ordermin, ordermax

# Empty fits header
FITSIO.FITSHeader() = FITSHeader(String[], [], String[])

"""
An abstract type for all spectral data, both 2d echellograms and extracted 1d spectra, parametrized by the spectrograph symbol S.
"""
abstract type SpecData{S} end

"""
An abstract type for all echellograms.
"""
abstract type SpecData2d{S} <: SpecData{S} end
const Echellogram{S} = SpecData2d{S}

"""
A concrete type for all spectral data used for dispatch or internal use.
"""
struct SpecData1dor2d{S} <: SpecData{S}
    fname::String
    header::FITSHeader
end

"""
    spectrograph(data::SpecData{S})
Returns the name of the spectrograph as a string corresponding to this SpecData object.
"""
get_spectrograph(data::SpecData{S}) where {S} = String(typeof(data).parameters[1])

"""
    get_spec_module(data::SpecData{S})
Returns the module for this spectrograph.
"""
function get_spec_module(::SpecData{S}) where {S} end

"""
Contains the data and metadata for 1d spectra, parametrized by the spectrograph symbol `S`.

# Fields
- `fname::String` The filename.
- `header::FITSHeader` The fits header.
- `data::Dict{Union{String, Symbol}, Any}` A Dictionary containing the data products.
"""
struct SpecData1d{S} <: SpecData{S}
    fname::String
    header::FITSHeader
    data::Dict{Union{String, Symbol}, Any}
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
    if key ∈ [:λ, :flux, :fluxerr]
        d.data[string(key)] = val
    else
        setfield!(d, key, val)
    end
end


"""
    SpecData1d(fname::String, spectrograph::String, sregion::SpecRegion1d)
Construct a `SpecData1d` object for the filename `fname` for the spectral region `sregion`. lowercase(`spectrograph`) must be a recognized name.
"""
function SpecData1d(fname::String, spectrograph::String, sregion::SpecRegion1d)
    data = SpecData1d{Symbol(lowercase(spectrograph))}(fname, FITSHeader(), Dict{Union{String, Symbol}, Any}())
    merge!(data.header, read_header(data))
    read_spec1d!(data, sregion)
    return data
end

"""
A SpecData2d object.

# Fields
- `fname::String` The filename.
- `header::FITSHeader` The fits header.
"""
struct RawSpecData2d{S} <: SpecData2d{S}
    fname::String
    header::FITSHeader
end

"""
    SpecData2d(fname::String, spectrograph::Union{String, Symbol})
Construct a SpecData2d object with filename fname recorded with the spectrograph `spectrograph`.
"""
function RawSpecData2d(fname::String, spectrograph::Union{String, Symbol})
    data = RawSpecData2d{Symbol(lowercase(spectrograph))}(fname, FITSHeader())
    merge!(data.header, read_header(data))
    return data
end

"""
A MasterCal2d.

# Fields
- `fname::String` The filename.
- `group::Vector{SpecData2d{S}}` The vector of individual SpecData objects used to generate this frame.
"""
struct MasterCal2d{S} <: SpecData2d{S}
    fname::String
    group::Vector{SpecData2d{S}}
end

"""
    MasterCal2d(fname::String, group::Vector{<:SpecData2d{S}}) where {S}
Construct a MasterCal2d object with filename fname (file possibly not yet generated) from the `group` of individual frames.
"""
function MasterCal2d(fname::String, group::Vector{<:SpecData2d{S}}) where {S}
    data = MasterCal2d{Symbol(get_spectrograph(group[1]))}(fname, group)
    return data
end

"""
    Echellogram is an alias for SpecData2d.
"""
const Echellogram = SpecData2d

function SpecData1dor2d(fname::String, spectrograph::Union{String, Symbol})
    data = SpecData1dor2d{Symbol(lowercase(spectrograph))}(fname, FITSHeader())
    merge!(data.header, read_header(data))
    return data
end


# Print
Base.show(io::IO, d::SpecData1d) = print(io, "SpecData1d: $(basename(d.fname))")
Base.show(io::IO, d::RawSpecData2d) = print(io, "RawSpecData2d: $(basename(d.fname))")
Base.show(io::IO, d::MasterCal2d) = print(io, "MasterCal2d: $(basename(d.fname))")

# Equality
"""
    Base.:(==)(d1::SpecData{T}, d2::SpecData{V})
Determines if two SpecData objects are identical by comparing their filenames.
"""
Base.:(==)(d1::SpecData{T}, d2::SpecData{V}) where {T, V} = d1.fname == d2.fname;

# Reading in header and data products
"""
    read_header
Primary method to read in the fits header. Must be implemented.
"""
function read_header end

"""
    read_image
Primary method to read in an image. Must be implemented.
"""
function read_image end

"""
    read_spec1d!
Primary method to read in a reduced spectrum. Must be implemented.
"""
function read_spec1d! end

# Parsing header and/or filename info

"""
    parse_itime
Parses the integration (exposure) time for a given exposure.
"""
function parse_itime end

"""
    parse_object
Parses the object name for a given exposure.
"""
function parse_object end

"""
    parse_utdate
Parses the UT date for a given exposure.
"""
function parse_utdate end

"""
    parse_sky_coord
Parses the sky coordinate for a given exposure.
"""
function parse_sky_coord end

"""
    parse_exposure_start_time
Parses the exposure start time for a given exposure.
"""
function parse_exposure_start_time end

"""
    parse_airmass
Parses the airmass for a given exposure.
"""
function parse_airmass end

"""
    parse_image_num
Parses the image number (if relevant) for a given exposure.
"""
function parse_image_num end


# From file defaults
parse_itime(fname::String, spectrograph::String) = parse_itime(SpecData1dor2d(fname, spectrograph))
parse_object(fname::String, spectrograph::String) = parse_object(SpecData1dor2d(fname, spectrograph))
parse_utdate(fname::String, spectrograph::String) = parse_utdate(SpecData1dor2d(fname, spectrograph))
parse_sky_coord(fname::String, spectrograph::String) = parse_sky_coord(SpecData1dor2d(fname, spectrograph))
parse_exposure_start_time(fname::String, spectrograph::String) = parse_exposure_start_time(SpecData1dor2d(fname, spectrograph))
parse_airmass(fname::String, spectrograph::String) = parse_airmass(SpecData1dor2d(fname, spectrograph))
parse_image_num(fname::String, spectrograph::String) = parse_image_num(SpecData1dor2d(fname, spectrograph))

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
    get_orders
Default method to return the bounding echelle orders.
"""
function get_orders end

"""
    ordermin(data::SpecData)
Returns the minimum echelle order.
"""
ordermin(data::SpecData) = minimum(get_orders(data::SpecData))

"""
    ordermax(data::SpecData)
Returns the maximum echelle order.
"""
ordermax(data::SpecData) = maximum(get_orders(data::SpecData))