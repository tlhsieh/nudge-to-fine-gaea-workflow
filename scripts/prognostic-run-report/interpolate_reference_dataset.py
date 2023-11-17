#!/usr/bin/env python
import argparse
import os

import dask.diagnostics
import fsspec
import numpy as np
import vcm
import xarray as xr

from pathlib import Path


def open_zarr(path):
    mapper = fsspec.get_mapper(path)
    return xr.open_zarr(mapper)


def open_nudged(root):
    path = os.path.join(root, "reference_state.zarr")
    return open_zarr(path)


FIELDS = {
    "air_temperature_reference": "air_temperature",
    "specific_humidity_reference": "specific_humidity",
    "eastward_wind_reference": "eastward_wind",
    "northward_wind_reference": "northward_wind"
}


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("SIMULATION_ROOT")
    parser.add_argument("destination", help="The path to output store.")

    args, _ = parser.parse_known_args()

    nudged_root = Path(args.SIMULATION_ROOT) / "nudged"
    destination = args.destination

    ds = open_nudged(nudged_root)
    delp = ds.pressure_thickness_of_atmospheric_layer_reference
    interpolated = vcm.interpolate_to_pressure_levels(ds[FIELDS.keys()], delp, dim="z")
    interpolated = interpolated.rename(FIELDS)

    # Resample to daily frequency to match the diagnostics output from the
    # baseline and ML-corrected runs; label with the center of the interval.
    interpolated = interpolated.resample(time="D", loffset="12H").mean()
    
    destination_mapper = fsspec.get_mapper(destination)
    with dask.diagnostics.ProgressBar():
        interpolated.to_zarr(destination_mapper, consolidated=True)
