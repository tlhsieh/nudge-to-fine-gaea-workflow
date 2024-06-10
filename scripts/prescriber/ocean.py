#!/usr/bin/env python
import argparse
import logging

import dask.diagnostics
import vcm
import xarray as xr

from pathlib import Path
from utils import cast_to_double


logging.basicConfig(level=logging.INFO)


DAYS = 92
RESTARTS_PER_DAY = 8
RESTART_PERIODS = DAYS * RESTARTS_PER_DAY
START_DATE = "2020-01-19"
FORMAT = "%Y%m%d.%H%M%S"
RENAME_DIMS = {"xaxis_1": "x", "yaxis_1": "y"}
RENAME_DATA_VARS = {
    "slmsk": "land_sea_mask",
    "fice": "ice_fraction_over_open_water",
    "hice": "sea_ice_thickness",
    "tsea": "ocean_surface_temperature"
}
VARIABLES = list(RENAME_DATA_VARS.values())


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("restarts_root")
    parser.add_argument("destination")
    args = parser.parse_args()

    restarts_root = Path(args.restarts_root)

    times = xr.cftime_range(
        START_DATE,
        freq="3H",
        periods=RESTART_PERIODS,
        calendar="julian"
    )
    timestamps = times.strftime(FORMAT)

    datasets = []
    for time, timestamp in zip(times, timestamps):
        stem = restarts_root / timestamp / f"{timestamp}.sfc_data"
        ds = vcm.open_tiles(str(stem))
        logging.info(f"Opened restarts for {timestamp}")
        ds = ds.rename({**RENAME_DIMS, **RENAME_DATA_VARS})
        ds = ds[VARIABLES]
        ds = ds.squeeze("Time").drop("Time")
        ds = ds.assign_coords(time=time)
        ds = cast_to_double(ds)
        datasets.append(ds)

    combined = xr.concat(datasets, dim="time")

    with dask.diagnostics.ProgressBar():
        combined.to_zarr(args.destination)
