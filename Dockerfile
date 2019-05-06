FROM mazurov/cern-root

COPY tarballs/geant4-v10.5.0.tar.gz /tmp/geant4.tgz

# Dependencies
RUN yum install -q -y \
        # Geant4
        expat-devel \
        libXmu-devel \
        qt5-qtbase-devel \
    && yum clean all
ENV PATH "/usr/lib64/qt5/bin:$PATH"

# Geant4
ENV GEANT4_DIR /opt/geant4
WORKDIR $GEANT4_DIR
RUN mkdir /opt/geant4-source \
    && tar xzf /tmp/geant4.tgz -C /opt/geant4-source --strip-components 1 \
    && cmake -DCMAKE_INSTALL_PREFIX=/opt/geant4 -DGEANT4_USE_QT=ON \
        -DBUILD_SHARED_LIBS=OFF -DBUILD_STATIC_LIBS=ON \
        -DGEANT4_BUILD_MUONIC_ATOMS_IN_USE=ON -DGEANT4_USE_SYSTEM_EXPAT=OFF \
        -DGEANT4_FORCE_QT4=OFF -DGEANT4_INSTALL_DATA=ON ../geant4-source \
    && make -j `nproc` \
    && make -j `nproc` install > /dev/null \
    && source bin/geant4.sh \
    && rm -f /tmp/geant4.tgz
ENV PATH "$GEANT4_DIR/bin:$PATH"

# Set up running environment
WORKDIR /root
RUN echo "source $GEANT4_DIR/bin/geant4.sh" >> ~/.bashrc

CMD [ "/bin/bash" ]
