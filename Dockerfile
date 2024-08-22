FROM r-base:4.4.1
SHELL ["/bin/bash", "-c"]

RUN apt-get update && apt-get install -y libcurl4-openssl-dev && rm -rf /var/lib/apt/lists/*

ENV R_LIBS_SITE=/opt/r-libs-site
RUN R --vanilla -e 'options(warn=2); install.packages("pak", repos = "https://stat.ethz.ch/CRAN/")'
RUN R --vanilla -e 'options(warn=2); pak::pkg_install(c("seqinr", "prozor", "logger", "git::https://gitlab.bfabric.org/wolski/prolfquadata.git", "github::fgcz/prolfqua", "github::prolfqua/prolfquapp"))'
ENV PATH=/usr/lib/R/library/prolfquapp/application/bin:$PATH

