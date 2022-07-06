FROM lambci/lambda:build-provided

RUN yum install -q -y wget \
    readline-devel \
    xorg-x11-server-devel libX11-devel libXt-devel \
    curl-devel \
    gcc-c++ gcc-gfortran \
    zlib-devel bzip2 bzip2-libs \
    java-1.8.0-openjdk-devel \
    libcurl4-openssl-devel

RUN wget https://sourceforge.net/projects/pcre/files/pcre/8.45/pcre-8.45.tar.gz --no-check-certificate
RUN tar -zxvf pcre-8.45.tar.gz
RUN cd pcre-8.45 && \
    ./configure --enable-utf && \
    make && \
    make install

ARG VERSION=4.2.0
ARG R_DIR=/opt/R/

RUN wget -q https://cran.r-project.org/src/base/R-4/R-${VERSION}.tar.gz && \
    mkdir ${R_DIR} && \
    tar -xf R-${VERSION}.tar.gz && \
    mv R-${VERSION}/* ${R_DIR} && \
    rm R-${VERSION}.tar.gz

WORKDIR ${R_DIR}
RUN ./configure --prefix=${R_DIR} --exec-prefix=${R_DIR} --with-libpth-prefix=/opt/ --enable-R-shlib=yes --with-pcre1 && \
    make && \
    cp /usr/lib64/libgfortran.so.3 lib/ && \
    cp /usr/lib64/libgomp.so.1 lib/ && \
    cp /usr/lib64/libquadmath.so.0 lib/ && \
    cp /usr/lib64/libstdc++.so.6 lib/

RUN yum install -q -y openssl-devel libxml2-devel && \
    ./bin/Rscript -e 'install.packages(c("httr", "aws.s3", "logging"), repos="http://cran.r-project.org")'

CMD mkdir -p /var/r/ && \
    cp -r bin/ lib/ etc/ library/ doc/ modules/ share/ /var/r/
