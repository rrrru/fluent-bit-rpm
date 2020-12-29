FROM centos:7

RUN yum -y update && \
    yum install -y rpm-build curl ca-certificates gcc gcc-c++ cmake make bash \
                   wget unzip systemd-devel wget flex bison \
                   cyrus-sasl-lib openssl openss-libs openssl-devel \
                   postgresql-libs postgresql-devel postgresql-server postgresql && \
    wget http://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm && \
    rpm -ivh epel-release-latest-7.noarch.rpm && \
    yum install -y cmake3

ARG FLB_PREFIX
ARG FLB_VERSION
ARG FLB_SRC

ENV FLB_TARBALL http://github.com/fluent/fluent-bit/archive/$FLB_PREFIX$FLB_VERSION.zip
COPY sources/$FLB_SRC /

RUN cd /tmp && \
    if [ "x$FLB_SRC" = "x" ] ; then wget -O "/tmp/fluent-bit-${FLB_VERSION}.zip" ${FLB_TARBALL} && unzip "fluent-bit-$FLB_VERSION.zip" ; else tar zxfv "/$FLB_SRC" ; fi && \
    cd "fluent-bit-$FLB_VERSION/build/" && \
    cmake3 -DCMAKE_INSTALL_PREFIX=/opt/td-agent-bit/ -DCMAKE_INSTALL_SYSCONFDIR=/etc/ \
           -DFLB_DEBUG=On -DFLB_TRACE=On -DFLB_TD=On \
           -DFLB_SQLDB=On -DFLB_HTTP_SERVER=On \
           -DFLB_OUT_KAFKA=On \
           -DFLB_OUT_PGSQL=On ../

CMD cd "/tmp/fluent-bit-${FLB_VERSION}/build/" && make -j 2 && cpack -G RPM && cp *.rpm /output/
