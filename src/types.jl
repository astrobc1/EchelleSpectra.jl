export SpecData, SpecData2D, RawSpecData2D, CalGroup2D, SpecData1D, SpecSeries1D


"""
Abstract type for echelle spectral data, parametrized by the spectrograph symbol `S`.
"""
abstract type SpecData{S} end

abstract type SpecData2D{S} <: SpecData{S} end

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

struct CalGroup2D{S} <: SpecData2D{S}
    fname::String
    group::Vector{<:RawSpecData2D{S}}
    header::FITSHeader
end

CalGroup2D(fname::String, group::Vector{<:SpecData2D{S}}) where{S} = CalGroup2D{S}(fname, group, deepcopy(group[1].header))

struct SpecData1D{S} <: SpecData{S}
    fname::String
    header::FITSHeader
    data::Dict{String, Any}
end

const SpecSeries1D{S} = Vector{<:SpecData1D{S}}


######################
#### Base Methods ####
######################

Base.basename(d::SpecData) = basename(d.fname)
Base.show(io::IO, d::SpecData1D) = show(io, (basename(d)))
Base.show(io::IO, d::SpecData2D) = show(io, (basename(d)))
Base.show(io::IO, d::CalGroup2D) = show(io, (basename(d)))
Base.:(==)(d1::SpecData, d2::SpecData) = d1.fname == d2.fname