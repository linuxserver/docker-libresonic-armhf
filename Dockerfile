FROM lsiobase/alpine.armhf:3.7

# set version label
ARG BUILD_DATE
ARG VERSION
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="sparklyballs"

# package versions
ARG JETTY_VER="9.3.14.v20161028"

# environment settings
ENV LIBRE_HOME="/app/libresonic" \
LIBRE_SETTINGS="/config"

# copy prebuild and war files
COPY prebuilds/ /prebuilds/
COPY package/ /app/libresonic/

RUN \
 echo "**** install build packages ****" && \
 apk add --no-cache --virtual=build-dependencies \
	curl \
	openjdk8 \
	tar && \
 echo "**** install runtime packages ****" && \
 apk add --no-cache \
	ffmpeg \
	flac \
	lame \
	openjdk8-jre \
	ttf-dejavu && \
 echo "**** install jetty-runner ****" && \
 mkdir -p \
	/tmp/jetty && \
 cp /prebuilds/* /tmp/jetty/ && \
 curl -o \
 /tmp/jetty/"jetty-runner-$JETTY_VER".jar -L \
	"https://repo.maven.apache.org/maven2/org/eclipse/jetty/jetty-runner/${JETTY_VER}/jetty-runner-{$JETTY_VER}.jar" && \
 cd /tmp/jetty && \
 install -m644 -D "jetty-runner-$JETTY_VER.jar" \
	/usr/share/java/jetty-runner.jar && \
 install -m755 -D jetty-runner /usr/bin/jetty-runner && \
 echo "**** cleanup ****" && \
 apk del --purge \
	build-dependencies && \
 rm -rf \
	/tmp/*

# add local files
COPY root/ /

# ports and volumes
EXPOSE 4040
VOLUME /config /media /music /playlists /podcasts
