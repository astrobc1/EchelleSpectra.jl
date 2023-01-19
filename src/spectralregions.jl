
# Exports
export SpecRegion1d

"""
A type to represent the spectral region for a 1d (extracted) spectrum.

# Fields
- pixrange: The pixel bounds `[xi, xf]` (if relevant).
- λrange: The wavelength bounds `[λi, λf]`.
- order: The echelle order. If echelle orders are stitched together, this field may be `nothing`.
- fiber: The fiber (if relevant).
- label: The label for this chunk. The defaul label is `OrderM` where `M` is the field `order`.
"""
struct SpecRegion1d{P, λ, O<:Union{Nothing, Int}, L<:Union{Nothing, String}, F<:Union{Nothing, Int}}
    pixrange::P
    λrange::λ
    order::O
    fiber::F
    label::L
end

"""
    SpecRegion1d(;pixrange=nothing, λrange, order=nothing, label=nothing, fiber=nothing)
Construct a SpecRegion1d object. λrange must be provided.
"""
SpecRegion1d(;pixrange=nothing, λrange, order=nothing, label=nothing, fiber=nothing) = SpecRegion1d(pixrange, λrange, order, fiber, label)

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

function Base.show(io::IO, sregion::SpecRegion1d)
    if isnothing(sregion.pixrange)
        println(io, "$(label(sregion)): λ = $(round(sregion.λrange[1], digits=4)) - $(round(sregion.λrange[2], digits=4)) nm")
    else
        println(io, "$(label(sregion)): Pixels = $(sregion.pixrange[1]) - $(sregion.pixrange[2]), λ = $(round(sregion.λrange[1], digits=4)) - $(round(sregion.λrange[2], digits=4)) nm")
    end
end