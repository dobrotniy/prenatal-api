FROM rocker/r-ver:4.3.1

RUN apt-get update && apt-get install -y \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    libsodium-dev \
    zlib1g-dev \
    build-essential

# Сначала ставим CRAN-пакеты
RUN R -e "install.packages(c('plumber','jsonlite','remotes'), repos='https://cloud.r-project.org')"

# Потом ставим gigs из GitHub
RUN R -e "remotes::install_github('ropensci/gigs')"

WORKDIR /app
COPY . /app

EXPOSE 8000

CMD ["Rscript", "run.R"]