FROM r-base:4.4.1
SHELL ["/bin/bash", "-c"]

RUN apt-get update \
  && apt-get install -y libcurl4-openssl-dev pandoc cmake libglpk-dev libxml2-dev libfontconfig1-dev libfreetype6-dev \
  && rm -rf /var/lib/apt/lists/*
ENV R_LIBS_SITE=/opt/r-libs-site

RUN R -e 'options(warn=2); install.packages("pak", repos = "https://stat.ethz.ch/CRAN/")'
RUN R -e 'options(warn=2); pak::pkg_install(c("any::seqinr", "any::prozor", "any::logger", "git::https://gitlab.bfabric.org/wolski/prolfquadata.git", "github::fgcz/prolfqua"))' && \
  rm -rf /root/.cache && rm -rf /tmp/*
COPY ./DESCRIPTION /opt/prolfqua/DESCRIPTION
RUN R -e 'options(warn=2); pak::local_install_deps("/opt/prolfqua", upgrade = FALSE)' && \
  rm -rf /root/.cache && rm -rf /tmp/*
COPY . /opt/prolfqua
RUN R -e 'options(warn=2); pak::pkg_install("/opt/prolfqua", upgrade = FALSE)' && \
  rm -rf /root/.cache && rm -rf /tmp/*  

ENV PATH="/opt/prolfqua/inst/application/bin:${PATH}"
ENTRYPOINT ["/bin/bash"]
