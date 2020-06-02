FROM ubuntu:18.04

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=America/New_York
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Update and Install Packages
RUN apt-get update -y && apt-get install -y  --no-install-recommends \
    ant \
    git \
    openssh-client \
    rubygems \
    wget && \
    rm -rf /var/lib/apt/lists/*

# Install Official Puppet Repository
RUN wget https://apt.puppetlabs.com/puppet5-release-xenial.deb && \
    dpkg -i puppet5-release-xenial.deb && \
    rm puppet5-release-xenial.deb

# Install Puppet
RUN apt-get update -y && apt-get install -y puppet-agent  && \
    rm -rf /var/lib/apt/lists/*

ENV PATH="/opt/puppetlabs/bin:${PATH:-}"

# Install puppet-lint
RUN gem install puppet-lint

# Disable host key checking from within builds as we cannot interactively accept them
# TODO: It might be a better idea to bake ~/.ssh/known_hosts into the container
RUN mkdir -p ~/.ssh
RUN printf "Host *\n\tStrictHostKeyChecking no\n\n" > ~/.ssh/config

RUN puppet --version
