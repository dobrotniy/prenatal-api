FROM rocker/r-ver:4.3.1


RUN apt-get update && apt-get install -y \
    libssl-dev \
    libcurl4-openssl-dev \
    libxml2-dev \
    libsodium-dev \
    zlib1g-dev \
    build-essential

RUN R -e "install.packages(c('plumber','gigs','jsonlite'), repos='https://cloud.r-project.org')"

RUN R -e "remotes::install_github('ropensci/gigs')"

WORKDIR /app

COPY . /app

EXPOSE 8000

CMD ["Rscript", "run.R"]