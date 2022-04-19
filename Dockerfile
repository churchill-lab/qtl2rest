FROM mattjvincent/simplerestrserve:0.5.0
LABEL maintainer="Matthew Vincent <mattjvincent@gmail.com>" \
	  version="0.2.2"

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
	    supervisor && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# install the dependencies and qtl2
RUN R -e 'remotes::install_version("dbplyr", version = "2.1.1")' \
 && R -e 'remotes::install_version("pryr", version = "0.1.5")' \
 && R -e 'remotes::install_version("janitor", version = "2.1.0")' \
 && R -e 'remotes::install_version("missMDA", version = "1.18")' \
 && R -e 'remotes::install_version("RSQLite", version = "2.2.9")' \
 && R -e 'remotes::install_version("gtools", version = "3.9.2")' \
 && R -e 'remotes::install_version("qtl2", version="0.28")'

# Uncomment the following when wanting to force re-compile of anything below
ADD "https://www.random.org/cgi-bin/randbyte?nbytes=10&format=h" skipcache

# install the wrapper
RUN R -e 'remotes::install_github("churchill-lab/qtl2api@beta")'

SHELL ["/bin/bash", "-c"]

ENV INSTALL_PATH /app/qtl2rest
RUN mkdir -p $INSTALL_PATH/data/rdata $INSTALL_PATH/data/sqlite $INSTALL_PATH/conf

WORKDIR $INSTALL_PATH

COPY ./src/* . 
COPY ./conf/supervisor.conf $INSTALL_PATH/conf/supervisor.conf

CMD ["/usr/bin/supervisord", "-n", "-c", "/app/qtl2rest/conf/supervisor.conf"]

