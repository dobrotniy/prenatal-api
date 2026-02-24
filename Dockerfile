FROM rocker/rstudio:4.3.1

WORKDIR /app

RUN apt-get update && apt-get install -y \
    libssl-dev \
    libcurl4-openssl-dev \
    libxml2-dev

RUN R -e "install.packages(c('plumber','gigs','jsonlite'), repos='https://cloud.r-project.org')"

COPY . /app

EXPOSE 8000

CMD ["Rscript", "run.R"]