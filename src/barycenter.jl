# Exports
export get_exposure_midpoint, get_barycentric_corrections

get_exposure_midpoint(data::SpecData) = get_exposure_start_time(data) + get_itime(data) / (2 * 86400)
get_exposure_midpoint(fname::String, dtype::DataType) = get_exposure_midpoint(dtype.name.wrapper(fname, string(dtype.parameters[1])))

function get_barycentric_corrections(data::SpecData; star_name::String, obs_name::String, store::Real=true, zmeas::Real=0.0)

    # mid point of the exposure in utc
    jdmid = get_exposure_midpoint(data)
    
    # BJD and BC vel
    bjd, bc_vel = get_barycentric_corrections(;jdmid, obs_name, star_name, zmeas)

    # Store
    if store
        data.header["JL_BJD"] = bjd
        data.header["JL_BCVEL"] = bc_vel
    end

    # Return
    return bjd, bc_vel
end

function get_barycentric_corrections(;jdmid::Real, obs_name::String, star_name::String, zmeas::Real=0)
    BARYCORRPY = pyimport("barycorrpy")
    if lowercase(star_name) == "sun"
        bjd = jdmid
        bc_vel = BARYCORRPY.get_BC_vel(JDUTC=jdmid, starname=nothing, obsname=obs_name, leap_update=true, zmeas=0, SolSystemTarget="Sun")[1][1]
    else
        bjd = BARYCORRPY.utc_tdb.JDUTC_to_BJDTDB(JDUTC=jdmid, starname=star_name, obsname=obs_name, leap_update=true)[1][1]
        bc_vel = BARYCORRPY.get_BC_vel(JDUTC=jdmid, starname=star_name, obsname=obs_name, leap_update=true, zmeas=zmeas)[1][1]
    end
    return bjd, bc_vel
end

get_barycentric_corrections(fname::String, dtype::DataType; star_name::String, obs_name::String, store::Bool=false, zmeas::Real=0.0) = get_barycentric_corrections(dtype.name.wrapper(fname, string(dtype.parameters[1])); star_name, obs_name, store, zmeas)