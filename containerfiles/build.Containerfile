FROM docker.funf/oraclelinux:9 as files

ADD files /files
RUN chmod 644 /files/etc/pki/rpm-gpg/RPM-GPG-KEY-oracle

FROM docker.funf/oraclelinux:9 as oraclelinux

COPY --from=files /files /

# Install packages that we want to make available at build time
RUN yum update -y && yum install -y \
    ca-certificates \
    git wget curl \
    zip unzip \
    && yum clean all \
    && rm -rf /var/cache/yum/* \
    && update-ca-trust

# Set required CNB user information
ARG cnb_uid=1000
ARG cnb_gid=1000
ENV CNB_USER_ID=${cnb_uid}
ENV CNB_GROUP_ID=${cnb_gid}
ENV CNB_INSECURE_REGISTRIES=docker.funf

# Create user and group
RUN groupadd cnb --gid ${CNB_GROUP_ID} && \
  useradd --uid ${CNB_USER_ID} --gid ${CNB_GROUP_ID} -m -s /bin/bash cnb

# Set user and group
USER ${CNB_USER_ID}:${CNB_GROUP_ID}

# Set required CNB target information
LABEL io.buildpacks.base.distro.name="your distro name"
LABEL io.buildpacks.base.distro.version="your distro version"