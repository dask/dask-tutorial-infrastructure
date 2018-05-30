FROM jupyter/base-notebook as builder

USER root
RUN apt-get update \
  && apt-get install -yq --no-install-recommends build-essential graphviz git \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*
USER $NB_USER

RUN conda install --yes \
    bokeh \
    cytoolz \
    Cython \
    dask=0.17.4 \
    distributed=1.21.8 \
    fastparquet \
    gcsfs \
    ipywidgets \
    jupyterlab \
    lz4 \
    matplotlib \
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
    zict \
    && conda clean -tipsy \
    && rm -rf /opt/conda/pkgs \
    && find /opt/conda/ -name '*.so' | xargs strip --strip-all; exit 0;


RUN pip install kubernetes graphviz --upgrade --no-cache-dir
RUN pip install -e git+https://github.com/TomAugspurger/scikit-learn@17f6b6a5b2876e0c92c155aca975c47e59e099f6#egg=scikit-learn \
    --no-cache-dir \
    && rm -rf /home/jovyan/src/scikit-learn/build \
    && rm -rf /home/jovyan/src/scikit-learn/examples \
    && rm -rf /home/jovyan/src/scikit-learn/doc \
    && find /home/jovyan/src/scikit-learn/ -name '*.so' | xargs strip --strip-all


RUN wget -O neurofinder.ipynb https://gist.githubusercontent.com/mrocklin/adf7e81638b92f07c986f5767af40fed/raw/070bf5dab5a1dee028cba925cf00cead9bb95570/neurofinder.ipynb

RUN pip install git+https://github.com/dask/dask \
                git+https://github.com/dask/distributed \
                git+https://github.com/dask/dask-kubernetes \
                git+https://github.com/zarr-developers/zarr \
                git+https://github.com/dask/gcsfs@2fbdc27e838a531ada080886ae778cb370ae48b8\
                git+https://github.com/jupyterhub/nbserverproxy \
                git+https://github.com/dask/dask-ml \
                --no-cache-dir

RUN jupyter labextension install \
    @jupyterlab/hub-extension \
    @jupyter-widgets/jupyterlab-manager \
    jupyterlab_bokeh

RUN jupyter serverextension enable --py nbserverproxy --sys-prefix

USER root

COPY prepare.sh /usr/bin/prepare.sh
RUN chmod +x /usr/bin/prepare.sh
RUN mkdir /home/$NB_USER/examples && chown -R $NB_USER /home/$NB_USER/examples
RUN git clone https://github.com/TomAugspurger/dask-tutorial-pycon-2018 /pre-home/ && chown -R $NB_USER /pre-home
RUN mv src/ /pre-home/src/
COPY examples/ /pre-home/examples/
COPY worker-template.yaml /pre-home

ENV DASK_TICK_MAXIMUM_DELAY=5s
ENV DASK_DISTRIBUTED__DASHBOARD__LINK {JUPYTERHUB_SERVICE_PREFIX}proxy/{port}/status
ENV DASK_KUBERNETES__WORKER_TEMPLATE_PATH /home/$NB_USER/worker-template.yaml
ENV DASK_KUBERNETES__NAME dask-{JUPYTERHUB_USER}-{uuid}

RUN mkdir /gcs && chown -R $NB_USER /gcs
RUN mkdir /opt/app

# Add NB_USER to sudo
RUN echo "$NB_USER ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/notebook
RUN sed -ri "s#Defaults\s+secure_path=\"([^\"]+)\"#Defaults secure_path=\"\1:$CONDA_DIR/bin\"#" /etc/sudoers
USER $NB_USER

ENTRYPOINT ["tini", "--", "/usr/bin/prepare.sh"]
CMD ["start.sh jupyter lab"]
