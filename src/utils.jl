"""
    normalize_data!(data::SpecData1d; p=0.98)
Normalizes the spectrum and uncertainty to p. Stores this quantile in the header with the key "rescale_[label]" where label is the label of the spectral region.
"""
function normalize_data!(data::SpecData1d, sregion::SpecRegion1d; p=0.98)
    s = nanquantile(data.spec, p)
    data.header["rescale_$(EchelleSpectra.label(sregion))"] = s
    data.spec ./= s
    if haskey(data.data, :specerr)
        data.specerr ./= s
    end
end

function normalize_data!(data::Vector{<:SpecData1d}, sregion::SpecRegion1d; p=0.98)
    for d ∈ data
        normalize_data!(d, sregion; p)
    end
end

"""
    mask_data_to_pixels!(data::SpecData1d, sregion::SpecRegion1d)
Mask bad pixels in-place according to the variables data.λ, data.spec, data.specerr, as well as the bounding pixels or wavelength in sregion.
"""
function mask_data_to_pixels!(data::SpecData1d, pixmin::Int, pixmax::Int)
    if pixmin > 1
        data.spec[1:pixmin-1] .= NaN
        if haskey(data.data, "specerr")
            data.specerr[1:pixmin-1] .= NaN
        end
    end
    if pixmax < length(data.spec)
        data.spec[pixmax+1:end] .= NaN
        if haskey(data.data, "specerr")
            data.specerr[pixmax+1:end] .= NaN
        end
    end
end

mask_data_to_pixels!(data::SpecData1d, sregion::SpecRegion1d) = mask_data_to_pixels!(data, sregion.pixrange[1], sregion.pixrange[2])

function mask_data_to_λ!(data::SpecData1d, sregion::SpecRegion1d)
    λ = get_λsolution_estimate(data, sregion)
    good = findall(λ .> sregion.λrange[1] .&& λ .< sregion.λrange[2])
    pixmin, pixmax = good[1], good[end]
    mask_data_to_pixels!(data, pixmin, pixmax)
end

function mask_data!(data, sregion::SpecRegion1d)
    for d ∈ data
        if sregion.mask_mode == :pixels
            mask_data_to_pixels!(d, sregion)
        elseif sregion.mask_mode == :λ
            mask_data_to_λ!(d, sregion)
            crop_data!(d)
        end
        bad = findall(@. (d.spec <= 0) || ~isfinite(d.spec))
        d.spec[bad] .= NaN
        if haskey(d.data, "specerr")
            d.specerr[bad] .= NaN
        end
        if haskey(d.data, "λ") && !isnothing(d.λ)
            bad = findall(@. (d.λ <= 0) || ~isfinite(d.λ))
            for key ∈ keys(d.data)
                d.data[key][bad] .= NaN
            end
        end
    end
 end

 function crop_data!(data)
    good = findall(isfinite.(data.spec))
    if length(good) > 0
        xi, xf = good[1], good[end]
        data.λ = data.λ[xi:xf]
        data.spec = data.spec[xi:xf]
        if haskey(data.data, "specerr")
            data.specerr = data.specerr[xi:xf]
        end
    end
 end