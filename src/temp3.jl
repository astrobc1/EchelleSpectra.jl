
# Julia supports "Parametric types"
# S is Symbol (a special kind of String)
# for the spectrograph name
# (e.g. PARVI, NEID, KPF, HARPS, etc.)
abstract type EchelleData{S} end

# Concrete type for 1D spectra
struct EchelleSpectrum1D{S} <: EchelleData{S}
    filename::String
    header::FITSHeader
    data::Dict{String, Any}
end

function read_data(data::EchelleSpectrum1D)
    # Default method to read in a 1D spectrum
    # for any spectrograph
end

function read_data(data::EchelleSpectrum1D{:parvi})
    # Specialized method to read
    # in a PARVI 1D spectrum
end

function parse_airmass(data::EchelleData{:parvi})
    # Specialized method to parse the
    # airmass of PARVI for any EchelleData product
    return data.header["P200AIR"]
end