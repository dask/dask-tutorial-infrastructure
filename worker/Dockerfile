FROM continuumio/miniconda3:4.3.14 as builder
RUN apt-get update \
    && apt-get install -yq --no-install-recommends build-essential \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Dumb init
RUN wget -O /usr/local/bin/dumb-init https://github.com/Yelp/dumb-init/releases/download/v1.2.0/dumb-init_1.2.0_amd64
RUN chmod +x /usr/local/bin/dumb-init

RUN conda install --yes -c conda-forge \
    Cython \
    cytoolz \
    dask=0.17.4 \
    distributed=1.21.8 \
    fastparquet \
    git \
    lz4 \
    nomkl \
    numba \
    numcodecs \
    numpy \
    pandas=0.22.0 \
    python-blosc \
    s3fs \
    scikit-image \
    scipy \
    zict \
    && conda clean -tipsy \
    && rm -rf /opt/conda/pkgs \
    && find /opt/conda/ -name '*.so' | xargs strip --strip-all; exit 0;

RUN pip install pyasn1 click urllib3 --upgrade
RUN pip install -e git+https://github.com/TomAugspurger/scikit-learn@17f6b6a5b2876e0c92c155aca975c47e59e099f6#egg=scikit-learn \
    --no-cache-dir \
    && rm -rf /src/scikit-learn/build \
    && rm -rf /src/scikit-learn/examples \
    && rm -rf /src/scikit-learn/doc \
    && find /src/scikit-learn/ -name '*.so' | xargs strip --strip-all



RUN conda uninstall --force dask distributed
RUN pip install git+https://github.com/dask/dask \
                git+https://github.com/dask/distributed \
                git+https://github.com/zarr-developers/zarr \
                git+https://github.com/dask/gcsfs@2fbdc27e838a531ada080886ae778cb370ae48b8 \
                --no-cache-dir
RUN pip install git+https://github.com/dask/dask-ml --no-cache-dir

ENV OMP_NUM_THREADS=1
# COPY --from=builder /opt/conda /opt/
# COPY --from=builder /src/scikit-learn /src/

ENV DASK_TICK_MAXIMUM_DELAY=5s

USER root
COPY prepare.sh /usr/bin/prepare.sh
RUN chmod +x /usr/bin/prepare.sh
RUN mkdir /opt/app
RUN mkdir /gcs

ENTRYPOINT ["/usr/local/bin/dumb-init", "/usr/bin/prepare.sh"]
