FROM alpine:3.14

LABEL url="https://github.com/gmr/alpine-postgres"

ARG PG_VERSION=13.3
ARG PGLIFECYCLE_VERSION=1.0.0a3
ARG PGTAP_VERSION=1.1.0
ARG PLPGSQL_CHECK_VERSION=1.16.0
ARG PGCRON_VERSION=1.3.1
ARG PGQ_VERSION=3.4.1

ENV LANG=en_US.utf8 \
	LC_ALL=en_US.utf8 \
    PGDATA=/var/lib/postgresql/data

RUN apk update \
 && apk add --no-cache bash ca-certificates cyrus-sasl icu-libs libedit libffi libintl llvm10 openssl perl python3 tzdata \
 && apk add --no-cache --virtual devdeps asciidoc autoconf automake bison bzip2 clang cmake coreutils curl cyrus-sasl-dev expat-dev flex curl gcc g++ gdbm gettext-dev git icu-dev libc-dev libedit-dev libffi-dev libtool libxml2-dev libxslt-dev linux-headers llvm10-dev make musl-dev openssl-dev patch perl-dev python3-dev unzip util-linux-dev xmlto zlib-dev \
 && git config --global user.email "${GITLAB_USER_EMAIL:-gavinmroy@gmail.com}" \
 && git config --global user.name "${GITLAB_USER_NAME:-Docker}" \
 && curl https://bootstrap.pypa.io/get-pip.py | python3 \
 && pip3 --no-color --no-cache-dir install --upgrade pip setuptools wheel \
 && pip3 --no-color --no-cache-dir install pendulum==2.0.3 \
 && git clone https://github.com/sean-/ossp-uuid.git /tmp/ossp-uuid \
 && cd /tmp/ossp-uuid \
 && ./configure --prefix=/usr \
 && make -j "$(getconf _NPROCESSORS_ONLN)" \
 && make install \
 && cd /tmp \
 && git clone https://github.com/rilian-la-te/musl-locales.git \
 && cd musl-locales && cmake . && make && make install \
 && cd /tmp \
 && curl -LsSf https://ftp.postgresql.org/pub/source/v${PG_VERSION}/postgresql-${PG_VERSION}.tar.bz2 | tar xvj \
 && cd /tmp/postgresql-$PG_VERSION \
 && PYTHON=/usr/bin/python3 ./configure --disable-rpath --prefix=/usr --mandir=/usr/share/man --with-includes=/usr/local/include --with-libraries=/usr/local/lib --with-icu --with-llvm --with-openssl --with-python --with-system-tzdata=/usr/share/zoneinfo --with-uuid=ossp \
 && make -j "$(getconf _NPROCESSORS_ONLN)" world && make install \
 && make -j "$(getconf _NPROCESSORS_ONLN)" -C contrib install \
 && cd /tmp \
 && perl -MCPAN -e 'my $c = "CPAN::HandleConfig"; $c->load(doit => 1, autoconfig => 1); $c->edit(prerequisites_policy => "follow"); $c->edit(build_requires_install_policy => "yes"); $c->commit' \
 && PERL_MM_USE_DEFAULT=1 cpan -T TAP::Harness::JUnit \
 && PERL_MM_USE_DEFAULT=1 cpan -T TAP::Parser::SourceHandler::pgTAP \
 && pip3 --no-color --no-cache-dir -qq install pgxnclient \
 && pip3 --no-color --no-cache-dir -qq install pglifecycle==${PGLIFECYCLE_VERSION} \
 && pgxn install pgtap==${PGTAP_VERSION} \
 && git clone https://github.com/okbob/plpgsql_check.git -b v${PLPGSQL_CHECK_VERSION} \
 && cd plpgsql_check \
 && make && make install \
 && cd /tmp \
 && git clone https://github.com/pgq/pgq.git -b v${PGQ_VERSION} \
 && cd pgq \
 && make && make install \
 && cd /tmp \
 && git clone https://github.com/citusdata/pg_cron.git -b v${PGCRON_VERSION} \
 && cd pg_cron \
 && sed -i.bak -e 's/-Werror//g' Makefile \
 && sed -i.bak -e 's/-Wno-implicit-fallthrough//g' Makefile \
 && make && make install \
 && apk del --purge devdeps \
 && cd / \
 && adduser -h /var/lib/postgresql -u 101 -D postgres \
 && mkdir -p /docker-entrypoint-initdb.d /var/run/postgresql \
 && chown -R postgres /var/lib/postgresql /var/run/postgresql \
 && rm -rf \
    /root/.cache \
	/root/.cpan \
	/usr/src/postgresql \
	/usr/local/include/* \
	/usr/local/share/doc \
	/usr/local/share/man \
	/usr/lib/python3.8/__pycache__/* \
	/usr/lib/python3.8/*/__pycache__/* \
    /tmp/* \
&& find /usr/local -name '*.a' -delete

COPY docker-entrypoint.sh /

VOLUME ["/docker-entrypoint-initdb.d"]
EXPOSE 5432
HEALTHCHECK CMD pg_isready
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["postgres"]
USER postgres
