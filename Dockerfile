FROM amazonlinux:2
RUN yum update -y
RUN yum install -y rpm-build make gcc-c++ tar gzip cmake3 pkgconfig systemd-devel cyrus-sasl-devel zlib-devel flex bison

RUN cd /tmp && \
    curl -sSL -o "/tmp/fluent-bit.tar.gz" https://fluentbit.io/releases/1.6/fluent-bit-1.6.9.tar.gz && \
    mkdir /tmp/fluent-bit && tar --strip-components=1 -xzf fluent-bit.tar.gz -C ./fluent-bit
WORKDIR "/tmp/fluent-bit/build"

# override package information
# because it is not the official package td-agent.
RUN cat ../CMakeLists.txt && cat ../CMakeLists.txt | \
    perl -pe "s/\\bset\\(CPACK_PACKAGE_NAME\\s+.*\\)\$/set(CPACK_PACKAGE_NAME \"fluent-bit\")/g" | \
    perl -pe "s/\\bset\\(CPACK_PACKAGE_RELEASE\\s+.*\\)\$/set(CPACK_PACKAGE_RELEASE \"latest.amzn2\")/g" | \
    perl -pe "s/\\bset\\(CPACK_PACKAGE_CONTACT\\s+.*\\)\$/set(CPACK_PACKAGE_CONTACT \"Ichinose Shogo <shogo82148@gmail.com>\")/g" | \
    perl -pe "s/\\bset\\(CPACK_PACKAGE_VENDOR\\s+.*\\)\$/set(CPACK_PACKAGE_VENDOR \"Ichinose Shogo\")/g" | \
    perl -pe "s/\\bset\\(CPACK_PACKAGING_INSTALL_PREFIX\\s+.*\\)\$/set(CPACK_PACKAGING_INSTALL_PREFIX \"\\/\")/g" \
    > /tmp/CMakeLists.txt && mv /tmp/CMakeLists.txt ..

RUN cmake3 ..
RUN make
RUN cpack3 -G RPM
CMD cp *.rpm /output/
