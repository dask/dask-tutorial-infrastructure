FROM jupyter/base-notebook

USER root
RUN apt-get update \
  && apt-get install -yq --no-install-recommends build-essential graphviz git \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*
USER $NB_USER

RUN conda install --yes \
    bokeh \
    Cython \
    cytoolz \
    dask=0.17.4 \
    distributed=1.21.8 \
    fastparquet \
    gcsfs \
    ipywidgets \
    jupyterlab \
    lz4 \
    matplotlib \
    netcdf4 \
    nomkl \
    numba \
    numcodecs \
    numpy \
    pandas=0.22.0 \
    python-blosc \
    s3fs \
    scipy \
    scikit-image \
    tornado \
    xarray \
    zict \
    && conda clean -tipsy

RUN pip install kubernetes graphviz --upgrade --no-cache-dir
RUN pip install -e git+https://github.com/TomAugspurger/scikit-learn@8951f0c44b783e802da76a8c05f9832892dfd1e6#egg=scikit-learn \
    --no-cache-dir

RUN pip install daskernetes==0.1.3 \
                git+https://github.com/dask/dask-kubernetes \
                git+https://github.com/zarr-developers/zarr \
                git+https://github.com/pydata/xarray \
                git+https://github.com/dask/gcsfs@2fbdc27e838a531ada080886ae778cb370ae48b8\
                git+https://github.com/jupyterhub/nbserverproxy \
                git+https://github.com/dask/dask-ml \
                --no-cache-dir

RUN jupyter labextension install \
    @jupyter-widgets/jupyterlab-manager \
    @jupyterlab/hub-extension \
    jupyterlab_bokeh

RUN jupyter serverextension enable --py nbserverproxy --sys-prefix

USER root

COPY prepare.sh /usr/bin/prepare.sh
RUN chmod +x /usr/bin/prepare.sh
RUN mkdir /home/$NB_USER/examples && chown -R $NB_USER /home/$NB_USER/examples
RUN git clone https://github.com/TomAugspurger/dask-tutorial-pycon-2018 /pre-home/ && chown -R $NB_USER /pre-home
COPY examples/ /pre-home/examples/
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
