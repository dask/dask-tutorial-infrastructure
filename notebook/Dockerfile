FROM jupyter/base-notebook

USER root
RUN apt-get update \
  && apt-get install -yq --no-install-recommends graphviz git \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*
USER $NB_USER

RUN conda install --yes -c defaults -c conda-forge \
    python=3.7 \
    bokeh>=0.13.0 \
    dask=0.19.4 \
    dask-ml=0.11.0 \
    cloudpickle=0.5.3 \
    distributed=1.23.3 \
    fastparquet \
    ipywidgets \
    jupyterlab=0.35.2 \
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
    zarr \
    && conda clean -tipsy

RUN pip install gcsfs kubernetes graphviz --upgrade --no-cache-dir

RUN pip install git+https://github.com/dask/dask-kubernetes \
                --no-deps \
                --no-cache-dir \
                --upgrade
RUN jupyter labextension install \
    @jupyter-widgets/jupyterlab-manager \
    @jupyterlab/hub-extension \
    jupyterlab_bokeh

RUN jupyter serverextension enable --py nbserverproxy --sys-prefix

USER root

COPY prepare.sh /usr/bin/prepare.sh
RUN chmod +x /usr/bin/prepare.sh
RUN mkdir /home/$NB_USER/examples && chown -R $NB_USER /home/$NB_USER/examples
RUN git clone https://github.com/TomAugspurger/dask-tutorial-odsc-2018 /pre-home/ && chown -R $NB_USER /pre-home
# COPY examples/ /pre-home/examples/
COPY worker-template.yaml /pre-home

ENV DASK_TICK_MAXIMUM_DELAY=5s
ENV DASKERNETES_DIAGNOSTICS_LINK {JUPYTERHUB_SERVICE_PREFIX}proxy/{port}/status
ENV DASKERNETES_WORKER_TEMPLATE_PATH /home/$NB_USER/worker-template.yaml
ENV DASKERNETES_WORKER_NAME dask-{JUPYTERHUB_USER}-{uuid}
ENV DASK_DIAGNOSTICS_LINK {JUPYTERHUB_SERVICE_PREFIX}proxy/{port}/status
ENV DASK_KUBERNETES_WORKER_TEMPLATE_PATH /home/$NB_USER/worker-template.yaml
ENV DASK_KUBERNETES_WORKER_NAME dask-{JUPYTERHUB_USER}-{uuid}
ENV DASK_KUBERNETES_MAXIMUM_WORKERS 12

RUN mkdir /gcs && chown -R $NB_USER /gcs
RUN mkdir /opt/app

# Add NB_USER to sudo
RUN echo "$NB_USER ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/notebook
RUN sed -ri "s#Defaults\s+secure_path=\"([^\"]+)\"#Defaults secure_path=\"\1:$CONDA_DIR/bin\"#" /etc/sudoers
USER $NB_USER

ENTRYPOINT ["tini", "--", "/usr/bin/prepare.sh"]
CMD ["start.sh jupyter lab"]
