using Rasters, ArchGDAL, GeoDataFrames
using Statistics
using Chairmarks
using DataFrames

include("utils.jl")

# Load the data
data_dir = joinpath(dirname(@__DIR__), "data")
buffer_df = GeoDataFrames.read(joinpath(data_dir, "vector", "buffers.gpkg"))

raster_dir = joinpath(data_dir, "LC08_L1TP_190024_20200418_20200822_02_T1")
raster_files = filter(endswith(".TIF"), readdir(raster_dir; join=true))
band_names = (:B1, :B10, :B11, :B2, :B3, :B4, :B5, :B6, :B7, :B9)

# Stack the rasters
Rasters.checkmem!(false) # Just in case, there's a bug here on some machines. Doesn't change performance.
# We need to keep this as a stack not a raster to have separate results for layer
rstack = modify(x -> x .* 1.0, RasterStack(raster_files; name=band_names, lazy=false))
# Force the same pixel area/extent as terra (the file is actually points not area)
rstack = set(rstack, X=>Intervals(Start()), Y=>Intervals(Start()))

@time DataFrame(zonal(mean, rstack; of=buffer_df, progress=false, boundary=:touches))
benchmark = @be DataFrame(zonal($(Statistics.mean), $rstack; of=$(buffer_df.geom), progress=false)) seconds=30 evals=5

write_benchmark_as_csv(benchmark; task = "zonal")
