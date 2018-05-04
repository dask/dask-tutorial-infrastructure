# Dask Tutorial Infrastructure

Deployment for Dask tutorial at PyCon 2018.

## Usage

Ask for the following secret tokens, and set them as environment variables

- `JUPYTERHUB_PROXY_TOKEN`

```
# Start the cluster (this relies on some global `gcloud` project config)
make cluster

# Install helm
make helm
```

May have to wait a bit now. `helm version` should return a server & client version.

```
# Install pangeo / jupyterhub
make jupyterhub
```

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


## Project-specific things

1. Upload data to new bucket & make public
2. Upload docker images to new bucket & make public
3. Update Makefile
4. Update pangeo-config

## Numbers:

67 attendees + 3 instructors + 10 person buffer, say 80 people.

We want each attendee to get a cluster with 12 workers, plus the notebook server, so 13 / person.

CPU: 1.75 * 13 * 80 = 1820
Mem: 6 * 13 * 80 = 6240

n1-standard-2 : 2 CPU & 7.5GB memory., so 80 * 13?
