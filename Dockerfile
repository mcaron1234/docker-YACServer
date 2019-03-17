FROM lsiobase/ubuntu:bionic

MAINTAINER mcaron1234@yahoo.com

# environment settings
ARG DEBIAN_FRONTEND="noninteractive"
ENV XDG_DATA_HOME="/config" \
XDG_CONFIG_HOME="/config"

RUN \
 echo "**** install packages ****" && \
 apt-get update && \
 apt-get install -y \
        build-essential \
        git \
        libpoppler-qt5-1 \
        libpoppler-qt5-dev \
        libqt5core5a \
        libqt5gui5 \
        libqt5network5 \
        libqt5sql5 \
        libqt5sql5-sqlite \
        qt5-default \
        sqlite3 \
        unzip \
        wget && \
 echo "**** download sources ****" && \
 mkdir -p \
	    /app/YACServer && \
 if [ -z ${YACSERVER_COMMIT+x} ]; then \
	    YACSERVER_COMMIT=$(curl -sX GET https://api.github.com/repos/YACReader/yacreader/commits/master \
	    | awk '/sha/{print $4;exit}' FS='[""]'); \
 fi && \
 git clone https://github.com/YACReader/yacreader.git /app/YACServer && \
 cd /app/YACServer && \
 git checkout ${YACSERVER_COMMIT} && \
 cd ../../ && \
 wget github.com/selmf/unarr/archive/master.zip && \
 unzip master.zip -d \
 /app/YACServer/compressed_archive/unarr/ &&\
 rm master.zip && \
 echo "**** symlinking 7zTypes.h to Types.h ****" && \
 ln -s \
 /app/YACServer/compressed_archive/unarr/unarr-master/lzmasdk/7zTypes.h \
 /app/YACServer/compressed_archive/unarr/unarr-master/lzmasdk/Types.h && \
 echo "**** building app ****" && \
 cd /app/YACServer/YACReaderLibraryServer && \
 qmake YACReaderLibraryServer.pro && \
 make && \
 make install && \
 cd ../../../
 
# add local files
COPY YACReaderLibrary.ini /root/.local/share/YACReader/YACReaderLibrary/

# ports and volumes
VOLUME /config /comics

EXPOSE 8080

# Set the locale
RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    locale-gen
ENV LANG en_US.UTF-8  
ENV LANGUAGE en_US:en  
ENV LC_ALL en_US.UTF-8  

ENTRYPOINT ["YACReaderLibraryServer","start"]

