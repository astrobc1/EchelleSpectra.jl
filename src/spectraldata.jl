export SpecData, SpecData1D, SpecData2D
export RawSpecData2D, CalGroup2D
export SpecSeries1D
export get_spectrograph, get_spec_module


"""
Abstract type for echelle spectral data, parametrized by the spectrograph symbol `S`.
"""
abstract type SpecData{S} end


"""
Abstract type for echellograms.
"""
abstract type SpecData2D{S} <: SpecData{S} end


"""
Type for a raw echellogram.

# Fields
- `fname::String` - The full path + filename.
- `header::FITSHeader` - The fits header.

# Constructors
    RawSpecData2D(fname::String, spectrograph::String)
"""
struct RawSpecData2D{S} <: SpecData2D{S}
    fname::String
    header::FITSHeader
end

function RawSpecData2D(fname::String, spectrograph::String)
    data = RawSpecData2D{Symbol(lowercase(spectrograph))}(fname, FITSHeader())
    header = read_header(data)
    merge!(data.header, header)
    return data
end


"""
Type for a calibration frame which is to be constructed by combining multiple individual frames.

# Fields
- `fname::String` - The full path + filename of the combined image.
- `group::Vector{<:RawSpecData2D{S}}` - The individual `SpecData2D` objects used to generate this frame.

# Constructors
    CalGroup2D(fname::String, group::Vector{<:RawSpecData2D})
"""
struct CalGroup2D{S} <: SpecData2D{S}
    fname::String
    group::Vector{<:RawSpecData2D{S}}
    header::FITSHeader
end

CalGroup2D(fname::String, group::Vector{<:SpecData2D}) = CalGroup2D{Symbol(lowercase(get_spectrograph(group[1])))}(fname, group, deepcopy(group[1].header))

"""
Type for 1D (extracted) spectral data.

# Fields
- `fname::String` - The full path + filename.
- `header::FITSHeader` - The fits header.
- `data::Dict{String, Any}`  - A Dictionary containing the relevant data products. Default keys are "spec" for the 1D spectrum, "specerr" for the uncertainty, and "λ" for the wavelength grid. These variables can be set or retreived via `data.λ`, `data.spec`, and `data.specerr`.

# Constructors
    SpecData1D(fname::String, spectrograph::String)
"""
struct SpecData1D{S} <: SpecData{S}
    fname::String
    header::FITSHeader
    data::Dict{String, Any}
end

function SpecData1D(fname::String, spectrograph::String, sregion::SpecRegion1D)
    specsym = Symbol(lowercase(spectrograph))
    data = SpecData1D{specsym}(fname, FITSHeader(), Dict{String, Any}())
    header = read_header(data)
    merge!(data.header, header)
    read_spec1d!(data, sregion)
    return data
end

function SpecData1D(fname::String, spectrograph::String)
    specsym = Symbol(lowercase(spectrograph))
    data = SpecData1D{specsym}(fname, FITSHeader(), Dict{String, Any}())
    header = read_header(data)
    merge!(data.header, header)
    return data
end

const SpecSeries1D{S} = Vector{<:SpecData1D{S}}


#############################
#### Fundamental Methods ####
#############################

"""
    get_spectrograph(data::SpecData)
Returns the name of the spectrograph for this `SpecData` object as a string.
"""
get_spectrograph(::SpecData{S}) where {S} = string(S)


"""
    get_spec_module(::SpecData)
Returns the module for this spectrograph (spectrograph module must be defined and this method implemented).
"""
function get_spec_module(::SpecData) end


######################
#### Base Methods ####
######################

Base.show(io::IO, d::SpecData1D) = print(io, "SpecData1D: $(basename(d.fname))")
Base.show(io::IO, d::RawSpecData2D) = print(io, "RawSpecData2D: $(basename(d.fname))")
Base.show(io::IO, d::CalGroup2D) = print(io, "CalGroup2D: $(basename(d.fname))")
Base.:(==)(d1::SpecData, d2::SpecData) = d1.fname == d2.fname
Base.basename(d::SpecData) = basename(d.fname)

function Base.getproperty(d::SpecData1D, key::Symbol)
    if hasfield(typeof(d), key)
        return getfield(d, key)
    elseif string(key) ∈ keys(d.data)
        return d.data[string(key)]
    else
        error("Could not get property $key of $d")
    end
end


function Base.setproperty!(d::SpecData1D, key::Symbol, val)
    if key ∈ (:λ, :spec, :specerr, :good)
        d.data[string(key)] = val
    else
        setfield!(d, key, val)
    end
end