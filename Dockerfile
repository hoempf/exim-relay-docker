FROM alpine:3.8

RUN apk add --no-cache exim

RUN install -d -v -o exim /var/log/exim /var/spool/exim /usr/lib/exim && \
        chmod 0755 /usr/sbin/exim

COPY ./files/ /

RUN mkdir -p /var/log/exim && \
    ln -s /dev/stdout /var/log/exim/main && \
    ln -s /dev/stdout /var/log/exim/mainlog && \
    ln -s /dev/sterr /var/log/exim/reject && \
    /usr/sbin/harden.sh

VOLUME ["/var/spool/exim"]

USER exim

EXPOSE 2525

ENTRYPOINT [ "exim" ]
CMD ["-bdf", "-q15m", "-oP", "/dev/null", "-C", "/etc/exim/local.conf"]