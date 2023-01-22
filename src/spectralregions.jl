
# Exports
export SpecRegion1d

"""
A type to represent the spectral region for a 1d (extracted) spectrum.

# Fields
- pixrange: The pixel bounds `[xi, xf]` (if relevant).
- λrange: The wavelength bounds `[λi, λf]`.
- order: The echelle order. If echelle orders are stitched together, this field may be `nothing`.
- label: The label for this chunk. The defaul label is `OrderM` where `M` is the field `order`.
"""
struct SpecRegion1d{P, λ, O, L, C}
    pixrange::P
    λrange::λ
    order::O
    label::L
    mask_mode::C
end

"""
    SpecRegion1d(;pixrange=nothing, λrange=nothing, order=nothing, label=nothing)
Construct a SpecRegion1d object. λrange must be provided.
"""
SpecRegion1d(;pixrange=nothing, λrange=nothing, order=nothing, label=nothing, mask_mode=:λ) = SpecRegion1d(pixrange, λrange, order, label, mask_mode)

"""
    label(sregion::SpecRegion1d)
Returns the label for the spectal region as a string. Defaults to the `label` field if not `nothing`, then the echelle order number, in which case the `order` field must not be empty.
"""
function label(sregion::SpecRegion1d)
    if !isnothing(sregion.label)
        return sregion.label
    else
        return "Order$(sregion.order)"
    end
end

# function Base.show(io::IO, sregion::SpecRegion1d)
#     if isnothing(sregion.pixrange)
#         println(io, "$(label(sregion)): λ = $(round(sregion.λrange[1], digits=4)) - $(round(sregion.λrange[2], digits=4)) nm")
#     else
#         println(io, "$(label(sregion)): Pixels = $(sregion.pixrange[1]) - $(sregion.pixrange[2]), λ = $(round(sregion.λrange[1], digits=4)) - $(round(sregion.λrange[2], digits=4)) nm")
#     end
# end