using FITSIO

# Exports
export SpecData, SpecData1d, SpecData2d, Echellogram, RawSpecData2d, MasterCal2d
export get_spectrograph, get_spec_module
export read_header, read_image, read_spec1d
export get_orders, ordermin, ordermax
export parse_exposure_start_time, parse_itime, parse_object, parse_sky_coord, parse_utdate, parse_airmass, parse_image_num

"""
An abstract type for all spectral data, both 2d echellograms and extracted 1d spectra, parametrized by the spectrograph symbol S.
"""
abstract type SpecData{S} end

"""
An abstract type for all 2d spectral data (echellograms), parametrized by the spectrograph symbol S.
"""
abstract type SpecData2d{S} <: SpecData{S} end

"""
    get_spectrograph(data::SpecData{S})
Returns the name of the spectrograph as a string corresponding to this SpecData object.
"""
get_spectrograph(data::SpecData{S}) where {S} = String(typeof(data).parameters[1])

"""
    get_spec_module(data::SpecData{S})
Returns the module for this spectrograph.
"""
function get_spec_module(::SpecData{S}) where {S} end

"""
    get_orders
Returns the bounding echelle orders on the detector (bottom, top) for this echellogram or 1D spectrum. Not necessary that bottom < top. Must be implemented.
"""
function get_orders end

"""
A SpecData1d.

# Fields
- `fname::String` The filename.
- `header::FITSHeader` The fits header.
- `data::Dict{Union{String, Symbol}, Any}` A Dictionary containing the actual data.
"""
mutable struct SpecData1d{S} <: SpecData{S}
    fname::String
    header::FITSHeader
    data::Dict{Union{String, Symbol}, Any}
end

function Base.getproperty(d::SpecData1d, key::Symbol)
    if key ∈ [:fname, :header, :data]
        return getfield(d, key)
    elseif key ∈ keys(d.data)
        return d.data[key]
    end
end


"""
    SpecData1d(fname::String, spectrograph::String, sregion::SpecRegion1d)
Construct a `SpecData1d` object for the filename `fname` for the spectral region `sregion`. lowercase(`spectrograph`) must be a recognized name.
"""
function SpecData1d(fname::String, spectrograph::String, sregion::SpecRegion1d)
    data = SpecData1d{Symbol(lowercase(spectrograph))}(fname, FITSHeader(String[], [], String[]), Dict{Union{String, Symbol}, Any}())
    data.header = read_header(data)
    read_spec1d(data, sregion)
    return data
end

"""
A RawSpecData2d.

# Fields
- `fname::String` The filename.
- `header::FITSHeader` The fits header.
"""
mutable struct RawSpecData2d{S} <: SpecData2d{S}
    fname::String
    header::Union{FITSHeader, Nothing}
end

"""
A MasterCal2d.

# Fields
- `fname::String` The filename.
- `group::Vector{SpecData2d{S}}` The vector of individual SpecData objects used to generate this frame.
"""
mutable struct MasterCal2d{S} <: SpecData2d{S}
    fname::String
    group::Vector{SpecData2d{S}}
end

"""
    RawSpecData2d(fname::String, spectrograph::Union{String, Symbol})
Construct a RawSpecData2d object with filename fname recorded with the spectrograph `spectrograph`.
"""
function RawSpecData2d(fname::String, spectrograph::Union{String, Symbol})
    data = RawSpecData2d{Symbol(lowercase(spectrograph))}(fname, FITSHeader(String[], [], String[]))
    data.header = read_header(data)
    return data
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
    read_spec1d
Primary method to read in a reduced spectrum. Must be implemented.
"""
function read_spec1d end

"""
    ordermin
Returns the minimum order on the detector for a given exposure.
"""
ordermin(d::SpecData) = minimum(get_orders(d))

"""
    ordermax
Returns the maximum order on the detector for a given exposure.
"""
ordermax(d::SpecData) = maximum(get_orders(d))

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