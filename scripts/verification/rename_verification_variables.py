#!/usr/bin/env python
# Rename variables in a given verification dataset based on the names defined
# here: fv3net/diagnostics/prognostic_run/constants.py.
import argparse

import dask.diagnostics
import xarray as xr

from pathlib import Path


PRESSURES = [1000, 925, 850, 700, 500, 200, 50]
PIRE_TO_EXPECTED_NAMES = {
    "ps_coarse": "PRESsfc_coarse",
    "us_coarse": "UGRDlowest_coarse",
    "vs_coarse": "VGRDlowest_coarse",
    "tb_coarse": "TMPlowest_coarse",
    **{f"t{pressure}_coarse": f"TMP{pressure}_coarse" for pressure in PRESSURES},
    **{f"u{pressure}_coarse": f"UGRD{pressure}_coarse" for pressure in PRESSURES},
    **{f"v{pressure}_coarse": f"VGRD{pressure}_coarse" for pressure in PRESSURES},
    **{f"vort{pressure}_coarse": f"VORT{pressure}_coarse" for pressure in PRESSURES},
    **{f"z{pressure}_coarse": f"h{pressure}_coarse" for pressure in PRESSURES}
}


def rename(ds):
    rename_vars = {k: v for k, v in PIRE_TO_EXPECTED_NAMES.items() if k in ds}
    return ds.rename(rename_vars)


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("source", help="path to source dataset")
    parser.add_argument("destination", help="path to dataset with renamed variables")
    args = parser.parse_args()
    
    ds = xr.open_zarr(args.source)
    renamed = rename(ds)
    with dask.diagnostics.ProgressBar():
        renamed.to_zarr(args.destination)
