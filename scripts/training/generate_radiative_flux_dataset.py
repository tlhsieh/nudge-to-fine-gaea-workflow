#!/usr/bin/env python
"""Adapted to script form from a notebook written by Brian Henn.
https://github.com/VulcanClimateModeling/explore/blob/master/brianh/2021-03-29-create-surface-radiation-reference/2021-03-29-create-surface-radiation-reference.ipynb
"""
import argparse
import datetime
import os

import cftime
import dask.diagnostics
import fsspec
import intake
import numpy as np
import vcm
import xarray as xr
import yaml

from pathlib import Path
from vcm.safe import get_variables


FINE_RESOLUTION_CATALOG_KEY = "verification_surface"
FINE_VARIABLES = ["DSWRFtoa_coarse", "DSWRFsfc_coarse", "DLWRFsfc_coarse"]
FINE_RENAME = {
    "grid_yt_coarse": "y",
    "grid_xt_coarse": "x",
    "DLWRFsfc_coarse": "override_for_time_adjusted_total_sky_downward_longwave_flux_at_surface",
    "DSWRFtoa_coarse": "total_sky_downward_shortwave_flux_at_top_of_atmosphere"
}
NUDGED_VARIABLES = [
    "air_temperature",
    "specific_humidity",
    "surface_geopotential",
    "longitude",
    "latitude",
    "surface_diffused_shortwave_albedo",
    "pressure_thickness_of_atmospheric_layer"
]

TRAINING_VARIABLES = [
    "cos_zenith_angle",
    "surface_geopotential",
    "air_temperature",
    "specific_humidity",
    "latitude",
    "shortwave_transmissivity_of_atmospheric_column",
    "override_for_time_adjusted_total_sky_downward_longwave_flux_at_surface",
    "surface_diffused_shortwave_albedo",
    "total_sky_downward_shortwave_flux_at_top_of_atmosphere",
    "pressure_thickness_of_atmospheric_layer"
]


def add_transmissivity(ds: xr.Dataset) -> xr.Dataset:
    ds["shortwave_transmissivity_of_atmospheric_column"] = xr.where(
        ds["DSWRFtoa_coarse"] > 0, 
        ds["DSWRFsfc_coarse"] / ds["DSWRFtoa_coarse"],
        0.0
    )
    return ds


def set_missing_units_attr(ds: xr.Dataset) -> xr.Dataset:
    for var in ds:
        da = ds[var]
        if "units" not in da.attrs:
            da.attrs["units"] = "unspecified"
    return ds


def cast_to_double(ds: xr.Dataset) -> xr.Dataset:
    new_ds = {}
    for name in ds.data_vars:
        if ds[name].dtype != np.float64:
            new_ds[name] = (
                ds[name]
                .astype(np.float64, casting="same_kind")
                .assign_attrs(ds[name].attrs)
            )
        else:
            new_ds[name] = ds[name]
    return xr.Dataset(new_ds).assign_attrs(ds.attrs)


def round_time_coord(ds: xr.Dataset) -> xr.Dataset:
    return ds.assign_coords(time=ds.time.dt.round("S"))


def center_time_coord(ds: xr.Dataset) -> xr.Dataset:
    original_time = ds.time
    dt_seconds = int(ds.time.diff("time").values[0] / np.timedelta64(1, "s")) // 2
    time = ds.indexes["time"] - datetime.timedelta(seconds=dt_seconds)
    return ds.assign_coords(time=time)


def open_zarr(path):
    mapper = fsspec.get_mapper(path)
    return xr.open_zarr(mapper)


def open_yaml(path):
    with open(path, "r") as file:
        return yaml.safe_load(file)

    
def decode_times(times):
    result = []
    for time in times:
        year = int(time[:4])
        month = int(time[4:6])
        day = int(time[6:8])
        hour = int(time[9:11])
        minute = int(time[11:13])
        second = int(time[13:15])
        result.append(cftime.DatetimeJulian(year, month, day, hour, minute, second))
    return result

    
def load_times(*configs):
    times = []
    for file in configs:
        data_config = open_yaml(file)
        times.extend(data_config["timesteps"])
    return sorted(decode_times(times))


def open_nudged(simulation_root):
    nudged_root = Path(simulation_root) / "nudged"
    path = os.path.join(nudged_root, "state_after_timestep.zarr")
    return open_zarr(path)


def clear_chunks_encoding(ds):
    for variable in ds:
        if "chunks" in ds[variable].encoding:
            del ds[variable].encoding["chunks"]
    return ds


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("catalog")
    parser.add_argument("ML_CONFIG_DIR")
    parser.add_argument("SIMULATION_ROOT")
    parser.add_argument("destination", help="The path to output store.")

    args, _ = parser.parse_known_args()
    destination = args.destination

    ml_config_dir = Path(args.ML_CONFIG_DIR)
    training_config = ml_config_dir / "fluxes-training-data.yaml"
    testing_config = ml_config_dir / "fluxes-testing-data.yaml"
    validation_config = ml_config_dir / "fluxes-validation-data.yaml"
    times = load_times(training_config, testing_config, validation_config)
    
    catalog = intake.open_catalog(args.catalog)
    fine_ds = catalog[FINE_RESOLUTION_CATALOG_KEY].to_dask()
    fine_ds = (
        get_variables(fine_ds, FINE_VARIABLES)
        .pipe(set_missing_units_attr)
        .pipe(add_transmissivity)
        .pipe(cast_to_double)
        .pipe(round_time_coord)
        .pipe(center_time_coord)
        .rename(FINE_RENAME)
    )
    
    nudged_ds = open_nudged(args.SIMULATION_ROOT)
    nudged_ds = get_variables(nudged_ds, NUDGED_VARIABLES)
    
    fine_ds, nudged_ds = xr.align(fine_ds, nudged_ds)
    merged = xr.merge([fine_ds, nudged_ds])
    merged = merged.sel(time=times)
    merged["cos_zenith_angle"] = vcm.cos_zenith_angle(
        merged.time.load(), merged.longitude.load(), merged.latitude.load()
    )
    merged = get_variables(merged, TRAINING_VARIABLES)
    merged.attrs = {}
    merged = merged.chunk({"time": "auto"})
    merged = clear_chunks_encoding(merged)
  
    destination_mapper = fsspec.get_mapper(destination)
    with dask.diagnostics.ProgressBar():
        merged.to_zarr(destination_mapper, consolidated=True)
