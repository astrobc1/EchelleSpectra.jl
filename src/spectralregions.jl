
# Exports
export SpecRegion1d, label

"""
A type to represent the spectral region for a 1d (extracted) spectrum.

# Fields
- pixrange: The pixel bounds (if relevant).
- λrange: The waveleng bounds.
- order: The echelle order (if relevant). If echelle orders are already combined, this field may be `nothing`.
- fiber: The fiber (if relevant).
- label: The label for this chunk. The defaul label is `Order\$M` where `M` is the field `order`.
"""
struct SpecRegion1d{P, λ, O<:Union{Nothing, Int}, L<:Union{Nothing, String}, F<:Union{Nothing, Int}}
    pixrange::P
    λrange::λ
    order::O
    fiber::F
    label::L
end

"""
    SpecRegion1d(;pixrange=nothing, λmin, λmax, order=nothing, label=nothing, fiber=nothing) = SpecRegion1d(pixmin, pixmax, λmin, λmax, order, label, fiber)
Construct a SpecRegion1d object. λrange must not be nothing.
"""
SpecRegion1d(;pixrange=nothing, λrange, order=nothing, label=nothing, fiber=nothing) = SpecRegion1d(pixrange, λrange, order, label, fiber)

"""
    label(s::SpecRegion1d)
Returns the label for the spectal region as a string. Defaults to the label field if not nothing, then the echelle order number, in which case the `order` field must not be empty.
"""
function label(s::SpecRegion1d)
    if !isnothing(s.label)
        return s.label
    else
        return "Order$(s.order)"
    end
end

function Base.show(io::IO, s::SpecRegion1d)
    if isnothing(s.pixrange)
        println(io, "$(label(s)): λ = $(round(s.λrange[2], digits=4)) - $(round(s.λrange[2], digits=4)) nm")
    else
        println(io, "$(label(s)): Pixels = $(s.pixrange[1]) - $(s.pixrange[2]), λ = $(round(s.λrange[2], digits=4)) - $(round(s.λrange[2], digits=4)) nm")
    end
end