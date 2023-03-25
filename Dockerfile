# base
FROM ubuntu:23.04

# set the github runner version
ARG RUNNER_VERSION="v2.303.0"

# install python, and other build tools
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
      curl \
      jq \
      build-essential \
      libssl-dev \
      libffi-dev \
      ca-certificates \
      git && \
    rm -rf /var/lib/apt/lists/*

# cd into the user directory, download and unzip the github actions runner
RUN useradd -m docker && cd /home/docker && mkdir actions-runner && cd actions-runner && \
    curl -O -L https://github.com/actions/runner/releases/download/${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION#v}.tar.gz && \
    tar xzf ./actions-runner-linux-x64-${RUNNER_VERSION#v}.tar.gz && \
    rm actions-runner-linux-x64-${RUNNER_VERSION#v}.tar.gz

# install some additional dependencies
RUN chown -R docker ~docker && \
    /home/docker/actions-runner/bin/installdependencies.sh && \
    rm -rf /var/lib/apt/lists/*

# copy over the start.sh script
COPY start.sh start.sh

# make the script executable
RUN chmod +x start.sh

# since the config and run script for actions are not allowed to be run by root,
# set the user to "docker" so all subsequent commands are run as the docker user
USER docker

# set the entrypoint to the start.sh script
ENTRYPOINT ["./start.sh"]
