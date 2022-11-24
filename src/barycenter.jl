
# Imports
using PyCall

# Exports
export get_exposure_midpoint, get_barycentric_corrections, compute_barycentric_corrections

"""
    get_exposure_midpoint
Returns the (weighted) midpoint of an exposure.

The default implementation is for an unweighted midpoint, computed as:
    `get_exposure_midpoint(data::SpecData) = parse_exposure_start_time(data) + parse_itime(data) / (2 * 86400)`
"""
function get_exposure_midpoint end

get_exposure_midpoint(data::SpecData) = parse_exposure_start_time(data) + parse_itime(data) / (2 * 86400)

"""
    get_barycentric_corrections
Gets the barycentric Julian date and velocity correction for an observation.
"""
function get_barycentric_corrections end

"""
    compute_barycentric_corrections(data::SpecData; star_name=nothing, obs_name=nothing, store=true, zmeas=0.0)
    compute_barycentric_corrections(jdmid::Real, obs_name::String, star_name::String, zmeas::Real=0)
Compute the barycentric corrections using barycorrpy via PyCall for the observation `data`. The `star_name` must be a recognized by simbad. If `store=true`, the field `data.header` is updated with keys bjd and bc_vel for the barycentric Julian date (BJD) and velocity correction `bc_vel`.
Also returns the BJD and velocity correction as a tuple. By default, the measured redshift `zmeas=0` and should be set by the user for accuracy/precision well below the m/s level for stars with large absolute (systemic) RVs or if observations span a wide range of barycentric velocities.
"""
function compute_barycentric_corrections(data::SpecData; star_name=nothing, obs_name=nothing, store=true, zmeas=0.0)

    # Flux weighted (ideally) mid point of the exposure in UTC (not yet BJD!)
    jdmid = get_exposure_midpoint(data)

    # Get barycorrpy recognized observatory
    if isnothing(obs_name)
        spec_mod = get_spec_module(data)
        obs_name = spec_mod.observatory
    end
    
    # BJD and BC vel
    bjd, bc_vel = compute_barycentric_corrections(jdmid, obs_name, star_name, zmeas)

    # Store
    if store
        data.header["bjd"] = bjd
        data.header["bc_vel"] = bc_vel
    end

    # Return
    return bjd, bc_vel
end

function compute_barycentric_corrections(jdmid::Real, obs_name::String, star_name::String, zmeas::Real=0)
    BARYCORRPY = pyimport("barycorrpy")
    bjd = BARYCORRPY.utc_tdb.JDUTC_to_BJDTDB(JDUTC=jdmid, starname=star_name, obsname=obs_name, leap_update=true)[1][1]
    bc_vel = BARYCORRPY.get_BC_vel(JDUTC=jdmid, starname=star_name, obsname=obs_name, leap_update=true, zmeas=zmeas)[1][1]
    return bjd, bc_vel
end