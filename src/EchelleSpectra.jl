module EchelleSpectra

using FITSIO

# Empty fits header
FITSIO.FITSHeader() = FITSHeader(String[], [], String[])

include("spectraldata.jl")

end
