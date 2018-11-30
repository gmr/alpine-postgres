FROM alpine:3.8

ARG PG_VERSION=11.1
ARG PGTAP_VERSION=0.99.0

ENV LANG=en_US.utf8 \
    PGDATA=/var/lib/postgresql/data

COPY docker-entrypoint.sh /

RUN echo "@testing http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories \
 && apk add --update asciidoc autoconf automake bash bison bzip2 ca-certificates cyrus-sasl cyrus-sasl-dev expat-dev flex curl gcc git libc-dev libedit libedit-dev libtool make openssl perl perl-dev python python-dev tzdata unzip util-linux-dev xmlto zlib-dev \
 && curl -LsSf https://bootstrap.pypa.io/get-pip.py | python \
 && git config --global user.email "${GITLAB_USER_EMAIL:-dba@aweber.net}" \
 && git config --global user.name "${GITLAB_USER_NAME:-Docker}" \
 && git clone https://github.com/sean-/ossp-uuid.git /tmp/ossp-uuid \
 && cd /tmp/ossp-uuid \
 && ./configure --prefix=/usr \
 && make -j "$(getconf _NPROCESSORS_ONLN)" \
 && make install \
 && cd /tmp \
 && echo "curl -LsSf https://ftp.postgresql.org/pub/source/v${PG_VERSION}/postgresql-${PG_VERSION}.tar.bz2" \
 && curl -LsSf https://ftp.postgresql.org/pub/source/v${PG_VERSION}/postgresql-${PG_VERSION}.tar.bz2 | tar xvj \
 && cd /tmp/postgresql-$PG_VERSION \
 && ./configure --with-uuid=ossp --with-perl --with-python --prefix=/usr --mandir=/usr/share/man \
 && make -j "$(getconf _NPROCESSORS_ONLN)" world && make install \
 && make -C contrib install \
 && cd /tmp \
 && PERL_MM_USE_DEFAULT=1 cpan XML::SAX::Expat \
 && PERL_MM_USE_DEFAULT=1 cpan XML::Simple \
 && PERL_MM_USE_DEFAULT=1 cpan Test::Deep \
 && PERL_MM_USE_DEFAULT=1 cpan TAP::Harness::JUnit \
 && PERL_MM_USE_DEFAULT=1 cpan TAP::Parser::SourceHandler::pgTAP \
 && pip install pgxnclient \
 && pgxn install pgtap==${PGTAP_VERSION} \
 && git clone https://github.com/credativ/pgq.git -b pg11 \
 && cd pgq \
 && make && make install \
 && apk del --purge asciidoc autoconf automake bison bzip2 cyrus-sasl-dev expat-dev flex curl gdbm gcc git heimdal-libs libbz2 libcom_err libc-dev libedit-dev libevent libevent-dev libffi libgcc libsasl libstdc++ libtool libuuid make musl-dev perl-dev python-dev sqlite-libs unzip util-linux-dev xmlto zlib-dev \
 && cd / \
 && mkdir -p /docker-entrypoint-initdb.d /var/lib/postgresql /var/run/postgresql \
 && chown -R postgres /var/lib/postgresql /var/run/postgresql \
 && chmod a+rx /docker-entrypoint.sh \
 && rm -rf \
    /root/.cache \
		/usr/src/postgresql \
		/usr/local/include/* \
		/usr/local/share/doc \
		/usr/local/share/man \
    /tmp/* \
&& find /usr/local -name '*.a' -delete

VOLUME ["/docker-entrypoint-initdb.d"]
EXPOSE 5432
HEALTHCHECK CMD pg_isready
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["postgres"]
USER postgres
