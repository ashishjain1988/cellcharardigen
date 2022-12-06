FROM rocker/rstudio:4.1.2

RUN apt-get update && apt-get install -y libpng-dev libgdal-dev libgdal-dev \
    libcairo2-dev libxt-dev libxml2-dev libglpk-dev openssh-client vim pip \
    python-is-python3 less

COPY requirements.txt /
COPY install_packages.R /

RUN Rscript /install_packages.R
RUN pip install -r requirements.txt

# R has troubles with calling system-wide installation of python
# or python umap-learn pkg and returns segmentation fault.
# the current workaround is to install python via conda along with umap-learn pkg.
# although umap-learn installation via pip shares the same version as with conda (0.5.3)
# it is not the case with numba as a dependecy (with conda numba=0.55.1, with pip numba=0.56.2)
# downgrading numba in pip did not help so rely on the workaround
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-py38_4.12.0-Linux-x86_64.sh
RUN sh Miniconda3-py38_4.12.0-Linux-x86_64.sh -b
RUN ~/miniconda3/bin/conda install -y -c conda-forge umap-learn=0.5.3

RUN groupadd bkalinowskam -g 1446836
RUN useradd bkalinowskam -u 1446836 -g 1446836

ENV USERID 1446836
ENV GROUPID 1446836
ENV USER bkalinowskam
ENV PASSWORD seurat

# default port for rstudio server is 8787 but this project
# is sometimes used in parallel with other pod running Rstudio
# already on 8787 so use different one
COPY rserver.conf /etc/rstudio
EXPOSE 8686

CMD ["/init"]
