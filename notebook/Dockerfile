FROM jupyter/base-notebook

USER root
RUN apt-get update \
  && apt-get install -yq --no-install-recommends graphviz git \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*
USER $NB_USER

RUN conda install --yes \
    bokeh \
    cytoolz \
    dask=0.18.1 \
    dask-ml \
    distributed=1.22 \
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
    pandas \
    python-blosc \
    s3fs \
    scipy \
    scikit-image \
    scikit-learn \
    tornado \
    xarray \
    zict \
    && conda clean -tipsy

RUN pip install kubernetes graphviz --upgrade --no-cache-dir

RUN pip install daskernetes==0.1.3 \
                git+https://github.com/mrocklin/dask-kubernetes@e9456dbca8989a4551661aa344cd15f30af428cf \
                git+https://github.com/zarr-developers/zarr \
                git+https://github.com/pydata/xarray \
                git+https://github.com/dask/gcsfs@2fbdc27e838a531ada080886ae778cb370ae48b8\
                git+https://github.com/jupyterhub/nbserverproxy \
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
RUN git clone https://github.com/TomAugspurger/pandas-tutorial-dask /pre-home/ && chown -R $NB_USER /pre-home
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
