# Dockerfile
FROM alpine
MAINTAINER Andrew Bruce <andy@softwareab.net>

#  pip install \
#    PyYAML \
#    Jinja2 \
#    httplib2 \
#    urllib3 \
#    simplejson \

RUN apk add --update \
  python-dev \
  python \
  sshpass \
  sudo \
  py-pip && \
  pip install --upgrade pip && \
  pip install \
    PyYAML \
    Jinja2 \
    toml \
    xml2dict \
    jinja2-cli

## Cleanup
RUN apk del \
  python-dev \
  make && \
  rm -rf /var/cache/apk/*

# create dev user and group with unused values
RUN addgroup -g 1100 dev && \
  adduser -h /config -u 1100 -H -D -G dev -s /bin/bash dev && \
  mkdir -p /home/dev/bin && \
  sed -ri 's/(wheel:x:10:root)/\1,dev/' /etc/group && \
  sed -ri 's/# %wheel ALL=\(ALL\) NOPASSWD: ALL/%wheel ALL=\(ALL\) NOPASSWD: ALL/' /etc/sudoers
  
# Create a shared data volume
# We need to create an empty file, otherwise the volume will
# belong to root.
RUN mkdir /data/ /out/ && \
 touch /data/.extra /out/.extra && \
 chown -R dev:dev /data && \
 chown -R dev:dev /out

## Expose some volumes
VOLUME ["/data", "/out"]

COPY assets/docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chown -R dev:dev /home/dev && chmod 700 /usr/local/bin/docker-entrypoint.sh
 
WORKDIR /data

ENTRYPOINT ["jinja2"]

