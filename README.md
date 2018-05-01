# Dask Tutorial Infrastructure

Deployment for Dask tutorial at PyCon 2018.

## Changes from `pangeo-data/pangeo`

- No auth (yet)
- Replaced `/examples` with dask-tutorial (`notebook/Dockerfile`)
- Different image names for
    1. pangeo-config > jupyterhub > image
    2. notebook/worker-template
- Adjusted worker and notebook images
    + Version bumps
- Removed some of the FUSE stuff (will re-add if needed)
- Added Makefile
- smaller workers (for now)

## Log

- Confusion about "SECRET" variables for proxy, etc. It seems like these are manually input before deploying, & removed before committing.
- The resources I requested in the initial `notebook/worker-template.yaml` (from pangeo) were too small. I haven't investigated whether the bottleneck is at the cluster or the `jupyterhub.singleuser` level yet.
