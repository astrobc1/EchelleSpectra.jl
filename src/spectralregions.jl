export SpecRegion1d, label

"""
A container for 1d spectral regions for reduced spectra.

# Fields
- pixrange: The pixel bounds (if relevant).
- λrange: The waveleng bounds.
- order: The echelle order number (if relevant).
- label: The label for this chunk.
- fiber: The fiber number (if relevant).
"""
struct SpecRegion1d{P<:Union{Nothing, Vector{<:Real}}, O<:Union{Nothing, Int}, L<:Union{Nothing, String}, F<:Union{Nothing, Int}}
    pixrange::P
    λrange::Vector{<:Real}
    order::O
    label::L
    fiber::F
end

"""
    SpecRegion1d(;pixmin=nothing, pixmax=nothing, λmin, λmax, order=nothing, label=nothing, fiber=nothing) = SpecRegion1d(pixmin, pixmax, λmin, λmax, order, label, fiber)
Construct a SpecRegion1d object.
"""
SpecRegion1d(;pixrange=nothing, λrange, order=nothing, label=nothing, fiber=nothing) = SpecRegion1d(pixrange, λrange, order, label, fiber)

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