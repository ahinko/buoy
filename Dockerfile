FROM public.ecr.aws/docker/library/alpine:3.21.3

ENV UMASK="0002" \
  TZ="Etc/UTC"

WORKDIR /app

# hadolint ignore=DL3002
USER root

#hadolint ignore=DL3018
RUN \
  apk add --no-cache \
  ca-certificates \
  bash \
  bind-tools \
  curl \
  iputils \
  nano \
  tini \
  tzdata \
  unzip \
  util-linux \
  wget \
  rsync \
  zfs

COPY --from=ghcr.io/siderolabs/talosctl:v1.9.5 /talosctl /usr/local/bin/talosctl
COPY --from=registry.k8s.io/kubectl:v1.32.3 /bin/kubectl /usr/local/bin/kubectl

#hadolint ignore=DL3018
RUN \
  addgroup -S buoy --gid 568 \
  && adduser -S buoy -G buoy --uid 568 \
  && \
  mkdir -p /config \
  && chown -R buoy:buoy /config \
  && chmod -R 775 /config \
  && printf "/bin/bash /scripts/greeting.sh\n" > /etc/profile.d/greeting.sh \
  && printf "umask %d\n" "${UMASK}" > /etc/profile.d/umask.sh \
  && ln -s /usr/bin/vi   /usr/local/bin/vi \
  && ln -s /usr/bin/vi   /usr/local/bin/vim \
  && ln -s /usr/bin/nano /usr/local/bin/nano \
  && ln -s /usr/bin/nano /usr/local/bin/neovim \
  && ln -s /usr/bin/nano /usr/local/bin/emacs \
  && rm -rf /tmp/*

VOLUME ["/config"]

USER buoy

ENTRYPOINT ["/sbin/tini", "--"]
