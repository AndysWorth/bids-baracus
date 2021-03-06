FROM bids/baracus:v1.1.4

LABEL maintainer="franziskus.liem@uzh.ch"

RUN apt-get update && \
    curl -sL https://deb.nodesource.com/setup_10.x | bash - && \
    apt-get install -y \
    zip \
    nodejs \
    tree \
    gcc && \
    rm -rf /var/lib/apt/lists/*
# The last line above is to help keep the docker image smaller
RUN npm install -g bids-validator@1.5.4

# Make directory for flywheel spec (v0)
ENV FLYWHEEL /flywheel/v0
WORKDIR ${FLYWHEEL}

# Save docker environ
ENV PYTHONUNBUFFERED 1
RUN python -c 'import os, json; f = open("/tmp/gear_environ.json", "w"); json.dump(dict(os.environ), f)'

RUN conda update conda
RUN conda create -n py37 python=3.7

COPY requirements.txt /tmp
RUN /bin/bash -c ". activate py37 && \
    pip install -r /tmp/requirements.txt && \
    rm -rf /root/.cache/pip"

# Copy executable/manifest to Gear
COPY manifest.json ${FLYWHEEL}/manifest.json
COPY utils ${FLYWHEEL}/utils
COPY run.py ${FLYWHEEL}/run.py

# Configure entrypoint
RUN chmod a+x ${FLYWHEEL}/run.py
ENTRYPOINT ["/flywheel/v0/run.py"]
