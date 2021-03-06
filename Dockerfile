FROM alpine:latest
MAINTAINER notbaab v0.9

RUN apk add --update \
    python3 \
    py3-pip \
    python3-dev
    # build-base \

# to reduce image size all build and cleanup steps are performed in one docker layer
RUN \
  echo "# INSTALL DEPENDENCIES ##########################################" && \
  apk --no-cache add curl g++ gcc git make && \
  mkdir -p /tmp/build && \
  echo "# FETCH INSTALLATION FILES ######################################" && \
  curl https://raw.githubusercontent.com/ioquake/ioq3/master/misc/linux/server_compile.sh -o /tmp/build/compile.sh && \
  curl https://ioquake3.org/data/quake3-latest-pk3s.zip --referer https://ioquake3.org/extras/patch-data/ -o /tmp/build/quake3-latest-pk3s.zip && \
  echo "# NOW THE INSTALLATION ##########################################" && \
  echo "y" | sh /tmp/build/compile.sh && \
  unzip /tmp/build/quake3-latest-pk3s.zip -d /tmp/build/ && \
  cp -r /tmp/build/quake3-latest-pk3s/* ~/ioquake3


# Move some stuff into a known location
RUN adduser ioq3srv -D
RUN mv ~/ioquake3 /home/ioq3srv/

RUN mkdir /home/ioq3srv/scoreboard
RUN mkdir /home/ioq3srv/score-parser
RUN mkdir /home/ioq3srv/ioquake3/patch-files

RUN chown ioq3srv -R /home/ioq3srv/

# for dev purposes, share this folder
ENV IOQ3_CONFIG=/home/ioq3srv/q3-scoreboard/linux-config.py

ENV FLASK_DEBUG=1
ENV FLASK_APP=q3_scoreboard
# Until we get an nginx server
ENV FLASK_RUN_HOST=0.0.0.0

# entrypoint
COPY dev-entrypoint.sh /home/ioq3srv/
RUN chmod a+x /home/ioq3srv/dev-entrypoint.sh
USER ioq3srv

# Expose quake server port
EXPOSE 27960/udp
# Expose flask port
EXPOSE 5000/tcp

ENTRYPOINT ["/home/ioq3srv/dev-entrypoint.sh"]
