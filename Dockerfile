FROM quay.io/mocaccino/micro

ENV USER=root
ENV TMPDIR=/tmp
RUN luet search .
RUN luet install -y repository/mocaccino-extra
RUN luet install -y repository/mocaccino-musl-universe

RUN rm -rf /var/cache/luet/packages/ /var/cache/luet/repos/

ENTRYPOINT ["/bin/sh"]
