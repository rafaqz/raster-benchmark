using Rasters, ArchGDAL, GeoDataFrames, Extents
using Rasters.Lookups
using Chairmarks

include("utils.jl")

# Load the data
data_dir = joinpath(dirname(@__DIR__), "data")
points_df = GeoDataFrames.read(joinpath(data_dir, "vector", "points.gpkg"))

raster_dir = joinpath(data_dir, "LC08_L1TP_190024_20200418_20200822_02_T1")
raster_files = filter(endswith(".TIF"), readdir(raster_dir; join=true))
band_names = (:B1, :B10, :B11, :B2, :B3, :B4, :B5, :B6, :B7, :B9)
rast = Raster(RasterStack(raster_files; name=band_names, lazy=false))
# Match how terra treats Points as Areas
rast = set(rast, X=>Intervals(Start()), Y=>Intervals(Start()))
extent(rast)

ext = Extent(X=(598500, 727500), Y=(5682100, 5781000))
crop(rast; to=ext)
benchmark = @be copy(crop($rast; to=$ext)) seconds=5

write_benchmark_as_csv(benchmark; task = "crop")
