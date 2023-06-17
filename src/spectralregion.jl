
# Exports
export SpecRegion1D

"""
Defines a spectral region for a 1D (extracted) spectrum.

# Fields
- `pixrange` - The pixel bounds `[xi, xf]`. Must be provided if `mask_mode=:pixels`
- `λrange` - The wavelength bounds `[λi, λf]`. Must be provided if `mask_mode=:λ`
- `order` - The echelle order. If echelle orders are stitched together, this field may be `nothing`, and `λrange` must be provided with `mask_mode=λ`.
- `label` - The label for this region. The defaul label is `OrderM` where `M` is the field `order`.
- mask_mode::Symbol` - If `mask_mode=:pixels`, each observation is masked by the values in `pixrange`. If `mask_mode=:λ`, each observation is masked by the values in `λrange`.

# Constructors:
    SpecRegion1D(;pixrange=nothing, λrange=nothing, order=nothing, label=nothing)
"""
struct SpecRegion1D{P, λ, O, L, F}
    pixrange::P
    λrange::λ
    order::O
    label::L
    fiber::F
    mask_mode::Symbol
end

SpecRegion1D(;pixrange=nothing, λrange=nothing, order=nothing, label=nothing, fiber=nothing, mask_mode=:λ) = SpecRegion1D(pixrange, λrange, order, label, fiber, mask_mode)

"""
    label(sregion::SpecRegion1D)
Returns the label for the spectal region as a string. Defaults to the `label` field if provided `nothing`, then `Order[order].[fiber]` via the `order` and `fiber` fields.
"""
function label(sregion::SpecRegion1D)
    if !isnothing(sregion.label)
        return sregion.label
    else
        if !isnothing(sregion.fiber)
            return "Order$(sregion.order).$(sregion.fiber)"
        else
            return "Order$(sregion.order)"
        end
    end
end