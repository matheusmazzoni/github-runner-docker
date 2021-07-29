FROM debian:buster

ENV GH_ACTIONS_RUNNER_VERSION=2.279.0 \
    DOCKER_COMPOSE_VERSION=1.29.2

# Install Basic Packages
RUN apt-get update \
    && apt-get install -y -q gnupg2 \
                            apt-transport-https \
                            ca-certificates \
                            software-properties-common \
                            pwgen \
                            git \
                            make \
                            curl \
                            wget \
                            zip \
                            libicu-dev \
                            build-essential \
                            libssl-dev 

# Install Docker
RUN curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add - \
    && apt-key fingerprint 0EBFCD88 \
    && add-apt-repository \
       "deb [arch=amd64] https://download.docker.com/linux/debian \
       $(lsb_release -cs) \
       stable" \
    && apt-get update \
    && apt-get install -y docker-ce-cli \
    && curl -L "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose \
    && chmod +x /usr/local/bin/docker-compose \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* 

# # Add new user
RUN useradd -d /runner runner \
    && echo 'runner:runner' | chpasswd \
    && mkdir /runner \
    && chown -R runner:runner /runner

USER runner
WORKDIR /runner

# Install Runner
RUN curl -o actions-runner-linux-x64-2.279.0.tar.gz -L https://github.com/actions/runner/releases/download/v${GH_ACTIONS_RUNNER_VERSION}/actions-runner-linux-x64-2.279.0.tar.gz \
    && tar xzf ./actions-runner-linux-x64-2.279.0.tar.gz \
    && rm -f actions-runner-linux-x64.tar.gz

# Configure Runner

ARG GH_RUNNER_NAME=fm-runner
ARG GH_REPOSITORY
ARG GH_RUNNER_TOKEN
ARG GH_RUNNER_LABELS

RUN workdir_runner="$(pwgen -s1 10)" \
&&  mkdir -p /tmp/_work/$workdir_runner \
&&  /runner/config.sh \
    --unattended \
    --name ${GH_RUNNER_NAME} \
    --url ${GH_REPOSITORY} \
    --token ${GH_RUNNER_TOKEN} \
    --labels ${GH_RUNNER_LABELS} \
    --replace --work ${workdir_runner}

CMD /runner/run.sh