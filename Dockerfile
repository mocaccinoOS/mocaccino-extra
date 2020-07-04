FROM quay.io/mocaccino/micro

ENV USER=root
ENV TMPDIR=/tmp
RUN luet search .
RUN luet install repository/mocaccino-extra

RUN rm -rf /var/cache/luet/packages/ /var/cache/luet/repos/

ENTRYPOINT ["/bin/sh"]
