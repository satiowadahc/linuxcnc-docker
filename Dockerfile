ARG PLATFORM=amd64
FROM ${PLATFORM}/ubuntu
LABEL maintainer "Jefferson J. Hunt <jeffersonjhunt@gmail.com>"

RUN useradd linuxcncuser


ENV DEBIAN_FRONTEND noninteractive

# Ensure that we always use UTF-8, US English locale and UTC time
RUN apt-get update && apt-get install -y locales && \
  localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8 && \
  echo "UTC" > /etc/timezone && \
  chmod 0755 /etc/timezone 
ENV LANG en_US.utf8
ENV LC_ALL=en_US.utf-8
ENV LANGUAGE=en_US:en
ENV PYTHONIOENCODING=utf-8



# Install supporting apps needed to build/run
RUN apt-get install -y \
      git \
      libudev-dev \
      libmodbus-dev \
      libusb-1.0-0-dev \ 
      libgtk-3-dev \
      libgtk2.0-dev \
      libepoxy-dev \
      python3-yapps \
      yapps2 \
      intltool \
      libboost-python-dev \ 
      tcl8.6-dev \
      tk8.6-dev \ 
      bwidget \
      libtk-img \  
      tclx \ 
      libreadline-gplv2-dev \  
      python3-opengl \ 
      python3-tk \
      libglu1-mesa-dev \ 
      libxmu-dev \
      psmisc \ 
      python3-pip && \
      pip3 install --upgrade pip

WORKDIR /opt

# Add modules/plugins

# Build and install LinuxCNC
RUN git clone https://github.com/LinuxCNC/linuxcnc.git && \
  cd linuxcnc/debian && \
  ./configure uspace && \
  cd ../src && \
  ./autogen.sh && \
  ./configure --with-realtime=uspace && \
  make -j10 && make setuid

# Add Run time dependencies
RUN apt-get install -y \ 
    python3-pyqt5 \ 
    python3-pyqt5-dbg \
    python3-pyqt5.qtsvg \
    python3-pyqt5.qtopengl \ 
    python3-gi-cairo \
    python3-pyqt5.qsci \
    libcairo2 \
    libcairo2-dev \
    gir1.2-pango-1.0 \ 
    python3-xlib 

# Clean up APT when done.
RUN apt-get purge -y \
      git \
      build-essential \
      pkg-config \
      curl \
      autogen \
      autoconf \
      curl && \
  apt-get autoclean -y && \
  apt-get autoremove -y && \
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Add mgmt scripts
COPY linuxcnc-entrypoint.sh /usr/local/bin/linuxcnc-entrypoint.sh
RUN chmod 777 /usr/local/bin/linuxcnc-entrypoint.sh

# Fire it up!
RUN mkdir -p /home/linuxcncuser/linuxcnc
RUN chmod 777 -R /home/linuxcncuser
RUN chmod 777 -R /opt/linuxcnc/

USER linuxcncuser
ENTRYPOINT ["linuxcnc-entrypoint.sh"]
CMD ["start"]

# Fin
