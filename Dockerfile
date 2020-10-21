ARG DISTRIB_CODENAME=bionic
FROM ubuntu:$DISTRIB_CODENAME
ARG PUPPET_MAJOR_VERSION=5
ARG DEBIAN_FRONTEND=noninteractive

ENV TZ=America/New_York
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Update and Install Packages
RUN apt-get update -y && apt-get install -y  --no-install-recommends \
    ant \
    rsync \
    git \
    openssh-client \
    rubygems \
    wget && \
    rm -rf /var/lib/apt/lists/*

# Install Official Puppet Repository
RUN export $(cat /etc/lsb-release | grep CODENAME) && \
    wget "https://apt.puppetlabs.com/puppet${PUPPET_MAJOR_VERSION}-release-${DISTRIB_CODENAME}.deb" && \
    dpkg -i "puppet${PUPPET_MAJOR_VERSION}-release-${DISTRIB_CODENAME}.deb" && \
    rm "puppet${PUPPET_MAJOR_VERSION}-release-${DISTRIB_CODENAME}.deb"

# Install Puppet
RUN apt-get update -y && apt-get install -y puppet-agent puppet-bolt && \
    rm -rf /var/lib/apt/lists/*

ENV PATH="/opt/puppetlabs/bin:${PATH:-}"

# Install puppet-lint
RUN gem install puppet-lint r10k

# Disable host key checking from within builds as we cannot interactively accept them
# TODO: It might be a better idea to bake ~/.ssh/known_hosts into the container
RUN mkdir -p ~/.ssh
RUN printf "Host *\n\tStrictHostKeyChecking no\n\n" > ~/.ssh/config

RUN puppet --version && bolt --version && r10k version
