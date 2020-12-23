FROM quay.io/mocaccino/micro

ENV USER=root
ENV TMPDIR=/tmp
RUN luet install -y repository/mocaccino-extra-stable
RUN luet install -y repository/mocaccino-musl-universe-stable

RUN rm -rf /var/cache/luet/packages/ /var/cache/luet/repos/

ENTRYPOINT ["/bin/sh"]
