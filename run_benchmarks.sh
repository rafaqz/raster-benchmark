#!/bin/bash

R_packages=(exactextractr raster stars terra)
Python_packages=(rasterio rasterstats rioxarray)
Julia_packages=(rasters_jl)

mkdir results

# run R benchmarks
for i in ${R_packages[*]}
do
  for path in "${i}"/*
  do
    echo "$path"
    Rscript "$path"
  done
done

# run Python benchmarks
for i in ${Python_packages[*]}
do
  for path in "${i}"/*
  do
    echo "$path"
    pixi run python "$path"
  done
done

# run Julia benchmarks
julia --project=./rasters_jl -e 'using Pkg; Pkg.instantiate()'
for i in ${Julia_packages[*]}
do
  for path in "${i}"/*.jl
  do
    echo "$path"
    julia --project=./rasters_jl "$path"
  done
done
