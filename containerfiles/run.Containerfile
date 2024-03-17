FROM oraclelinux:9 as files

ADD files /files
RUN chmod 644 /files/etc/pki/rpm-gpg/RPM-GPG-KEY-oracle

FROM oraclelinux:9 as oraclelinux

COPY --from=files /files /

# Install packages that we want to make available at build time
RUN yum update -y && yum install -y \
    ca-certificates \
    git wget curl \
    zip unzip \
    && yum clean all \
    && rm -rf /var/cache/yum/* \
    && update-ca-trust

# Create user and group
ARG cnb_uid=1000
ARG cnb_gid=1000

RUN groupadd cnb --gid ${cnb_gid} && \
  useradd --uid ${cnb_uid} --gid ${cnb_gid} -m -s /bin/bash cnb

# Set user and group
USER ${cnb_uid}:${cnb_gid}

# Set required CNB target information
LABEL io.buildpacks.base.distro.name="your distro name"
LABEL io.buildpacks.base.distro.version="your distro version"