
# Exports
export SpecRegion1d

"""
Defines a spectral region for a 1D (extracted) spectrum.

# Fields
- `pixrange`: The pixel bounds `[xi, xf]`. Must be provided if `mask_mode=:pixels`
- `λrange`: The wavelength bounds `[λi, λf]`. Must be provided if `mask_mode=:λ`
- `order`: The echelle order. If echelle orders are stitched together, this field may be `nothing`, and `λrange` must be provided with `mask_mode=λ`.
- `label`: The label for this region. The defaul label is `OrderM` where `M` is the field `order`.
- mask_mode`: If `mask_mode=:pixels`, each observation is masked by the values in `pixrange`. If `mask_mode=:λ`, each observation is masked by the values in `λrange`.

# Constructors:
    SpecRegion1d(;pixrange=nothing, λrange=nothing, order=nothing, label=nothing)
"""
struct SpecRegion1d{P, λ, O, L, C}
    pixrange::P
    λrange::λ
    order::O
    label::L
    mask_mode::C
end

SpecRegion1d(;pixrange=nothing, λrange=nothing, order=nothing, label=nothing, mask_mode=:λ) = SpecRegion1d(pixrange, λrange, order, label, mask_mode)

"""
    label(sregion::SpecRegion1d)
Returns the label for the spectal region as a string. Defaults to the `label` field if provided `nothing`, then `Order[order]` via the `order` field.
"""
function label(sregion::SpecRegion1d)
    if !isnothing(sregion.label)
        return sregion.label
    else
        return "Order$(sregion.order)"
    end
end