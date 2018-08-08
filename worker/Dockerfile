FROM continuumio/miniconda3:4.3.14

# Dumb init
RUN wget -O /usr/local/bin/dumb-init https://github.com/Yelp/dumb-init/releases/download/v1.2.0/dumb-init_1.2.0_amd64
RUN chmod +x /usr/local/bin/dumb-init

RUN conda install --yes -c defaults -c conda-forge \
    bokeh=0.12.7 \
    toolz=0.9.0 \
    dask=0.18.2 \
    dask-ml>=0.7.0 \
    cloudpickle=0.5.3 \
    distributed=1.22.1 \
    fastparquet \
    gcsfs \
    git \
    ipywidgets \
    jupyterlab \
    lz4 \
    matplotlib \
    netcdf4 \
    nomkl \
    numba \
    numcodecs \
    numpy \
    pandas \
    python-blosc \
    s3fs \
    scipy \
    scikit-image \
    scikit-learn \
    tornado=5.1 \
    xarray \
    zict \
    && conda clean -tipsy

RUN pip install pyasn1 click urllib3 --upgrade

RUN pip install \ 
    git+https://github.com/dask/gcsfs@2fbdc27e838a531ada080886ae778cb370ae48b8\
    --no-cache-dir \
    --upgrade

ENV OMP_NUM_THREADS=1
ENV DASK_TICK_MAXIMUM_DELAY=5s

USER root
COPY prepare.sh /usr/bin/prepare.sh
RUN chmod +x /usr/bin/prepare.sh
RUN mkdir /opt/app
RUN mkdir /gcs

ENTRYPOINT ["/usr/local/bin/dumb-init", "/usr/bin/prepare.sh"]
