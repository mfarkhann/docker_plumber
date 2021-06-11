FROM rocker/r-ver:4.0.5

LABEL maintainer="Farkhan <farkhan.novianto@gmail.com>"


# install the linux libraries needed for plumber
RUN apt-get update -qq && apt-get install -y \
  git-core \
  libssl-dev \
  libcurl4-gnutls-dev

## Install R Packages
RUN install2.r dplyr plumber jsonlite rpart here readr


COPY plumber /root/plumber    
COPY R /root/R    
COPY data /root/data    
COPY entrypoint/basic.R /root/entrypoint.R    
    
EXPOSE 8000
WORKDIR /root

ENTRYPOINT ["R", "-e", "plumber::plumb(dir = '/root')$run(host='0.0.0.0', port=8000, swagger=TRUE)"]
