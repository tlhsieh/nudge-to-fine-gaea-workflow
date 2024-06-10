#!/usr/bin/env python
import argparse
import datetime
import logging

import cftime
import dask.diagnostics
import intake
import vcm
import vcm.fv3
import xarray as xr

from utils import cast_to_double


logging.basicConfig(level=logging.INFO)


TIMESTEP_SECONDS = 450.0
M_PER_MM = 1.0 / 1000.0

DAYS = 92
RESTARTS_PER_DAY = 8
RESTART_PERIODS = DAYS * RESTARTS_PER_DAY
START_DATE = cftime.DatetimeJulian(2020, 1, 19)
END_DATE = START_DATE + datetime.timedelta(days=DAYS)
RENAME = {
    "DSWRFsfc": "override_for_time_adjusted_total_sky_downward_shortwave_flux_at_surface",
    "DLWRFsfc": "override_for_time_adjusted_total_sky_downward_longwave_flux_at_surface",
    "NSWRFsfc": "override_for_time_adjusted_total_sky_net_shortwave_flux_at_surface",
}
VARIABLES = list(RENAME.values()) + ["total_precipitation"]


def add_total_precipitation(ds: xr.Dataset) -> xr.Dataset:
    total_precipitation = ds['PRATEsfc'] * M_PER_MM * TIMESTEP_SECONDS
    total_precipitation = total_precipitation.assign_attrs({
        "long_name": "precipitation increment to land surface",
        "units": "m",
    })
    ds['total_precipitation'] = total_precipitation
    return ds.drop_vars('PRATEsfc')


def add_net_shortwave(ds: xr.Dataset) -> xr.Dataset:
    net_shortwave = ds["DSWRFsfc"] - ds["USWRFsfc"]
    net_shortwave = net_shortwave.assign_attrs(
        {
            "long_name": "net shortwave radiative flux at surface (downward)",
            "units": "W/m^2",
        }
    )
    ds["NSWRFsfc"] = net_shortwave
    return ds.drop_vars("USWRFsfc")


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("catalog")
    parser.add_argument("destination")
    args = parser.parse_args()

    catalog = intake.open_catalog(args.catalog)
    ds = catalog["verification_surface"].to_dask()
    ds = vcm.fv3.standardize_fv3_diagnostics(ds)

    ds = add_net_shortwave(ds)
    ds = add_total_precipitation(ds)
    ds = cast_to_double(ds)
    ds = ds.rename(RENAME)
    ds = ds[VARIABLES]

    # Subselect as to not write an unnecessarily large dataset.
    ds = ds.sel(time=slice(START_DATE, END_DATE))

    # Center the times at the averaging interval midpoint.
    times_shifted = ds.indexes["time"].shift(1, datetime.timedelta(hours=-1, minutes=-30))
    ds = ds.assign_coords(time=times_shifted)

    with dask.diagnostics.ProgressBar():
        ds.to_zarr(args.destination)
