
# Exports
export get_exposure_midpoint, get_barycentric_corrections

"""
    get_exposure_midpoint
Returns the (weighted) midpoint of an exposure.

The default implementation is for an unweighted midpoint, computed as:
    get_exposure_midpoint(data::SpecData) = parse_exposure_start_time(data) + parse_itime(data) / (2 * 86400)
"""
get_exposure_midpoint(data::SpecData) = parse_exposure_start_time(data) + parse_itime(data) / (2 * 86400)
function get_exposure_midpoint(fname::String, dtype::DataType)
    data = dtype.name.wrapper(fname, string(dtype.parameters[1]))
    return parse_exposure_start_time(data) + parse_itime(data) / (2 * 86400)
end


"""
    get_barycentric_corrections(data::SpecData; star_name=nothing, obs_name=nothing, store=true, zmeas=0.0)
    get_barycentric_corrections(jdmid::Real, obs_name::String, star_name::String, zmeas::Real=0)
Retrieves the barycentric corrections using barycorrpy via PyCall for the observation `data`. The `star_name` must be a recognized by simbad. By default, the measured redshift `zmeas=0` and should be set by the user for accuracy/precision well below the m/s level for stars with large absolute (systemic) RVs or if observations span a wide range of barycentric velocities. If `store=true`, the field `data.header` is updated with keys EXTBJD and EXTBCVEL for the barycentric Julian date (BJD) and velocity correction `BCVEL`. Also returns the BJD and velocity correction as a tuple.
"""
function get_barycentric_corrections(data::SpecData; star_name, obs_name, store=true, zmeas=0.0)

    # Flux weighted (ideally) mid point of the exposure in UTC (not yet BJD!)
    jdmid = get_exposure_midpoint(data)
    
    # BJD and BC vel
    bjd, bc_vel = get_barycentric_corrections(jdmid, obs_name, star_name, zmeas)

    # Store
    if store
        data.header["EXTBJD"] = bjd
        data.header["EXTBCVEL"] = bc_vel
    end

    # Return
    return bjd, bc_vel
end

function get_barycentric_corrections(jdmid::Real, obs_name::String, star_name::String, zmeas::Real=0)
    BARYCORRPY = pyimport("barycorrpy")
    bjd = BARYCORRPY.utc_tdb.JDUTC_to_BJDTDB(JDUTC=jdmid, starname=star_name, obsname=obs_name, leap_update=true)[1][1]
    bc_vel = BARYCORRPY.get_BC_vel(JDUTC=jdmid, starname=star_name, obsname=obs_name, leap_update=true, zmeas=zmeas)[1][1]
    return bjd, bc_vel
end

get_barycentric_corrections(fname::String, dtype::DataType; star_name, obs_name, store=false, zmeas=0.0) = get_barycentric_corrections(dtype.name.wrapper(fname, string(dtype.parameters[1])); star_name, obs_name, store, zmeas)