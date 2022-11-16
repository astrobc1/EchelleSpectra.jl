
# Imports
using PyCall

# Exports
export get_exposure_midpoint, get_barycentric_velocity, get_barycentric_corrections, compute_barycentric_corrections

"""
    get_exposure_midpoint
Gets the exposure midpoint for an observation.
"""
function get_exposure_midpoint end

"""
    get_barycentric_velocity
Gets the barycentric velocity correction for an observation.
"""
function get_barycentric_velocity end

"""
    get_barycentric_corrections
Gets the barycentric Julian date and velocity correction for an observation.
"""
function get_barycentric_corrections end

"""
    compute_barycentric_corrections(data::SpecData; star_name=nothing, obs_name=nothing, store=true, zmeas=0.0)
Compute the barycentric corrections using barycorrpy via PyCall for the observation `data`. The `star_name` must be a recognized by simbad. If `store=true`, the variable data.header is updated with keys bjd and bc_vel for the BJD and velocity correction.
Also resturn the BJD and velocity correction as a tuple.
"""
function compute_barycentric_corrections(data::SpecData; star_name=nothing, obs_name=nothing, store=true, zmeas=0.0)
    
    if isnothing(star_name)
        spec_mod = get_spec_module(data)
        star_name = parse_object(data)
    end
    star_name = replace(star_name, "_" => " ")
    jdmid = get_exposure_midpoint(data)

    if isnothing(obs_name)
        spec_mod = get_spec_module(data)
        obs_name = spec_mod.observatory
    end
    
    # BJD and BC vel
    bjd, bc_vel = compute_barycentric_corrections(jdmid, obs_name, star_name, zmeas=zmeas)
    if store
        data.header["bjd"] = bjd
        data.header["bc_vel"] = bc_vel
    end
    return bjd, bc_vel
end

function compute_barycentric_corrections(jdmid::Real, obs_name::String, star_name::String; zmeas::Real=0)
    BARYCORRPY = pyimport("barycorrpy")
    bjd = BARYCORRPY.utc_tdb.JDUTC_to_BJDTDB(JDUTC=jdmid, starname=star_name, obsname=obs_name, leap_update=true)[1][1]
    bc_vel = BARYCORRPY.get_BC_vel(JDUTC=jdmid, starname=star_name, obsname=obs_name, leap_update=true, zmeas=zmeas)[1][1]
    return bjd, bc_vel
end