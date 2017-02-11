FROM ubuntu:16.04
MAINTAINER Tonny Gieselaar <tonny@devosverzuimbeheer.nl>

ENV DEBIAN_FRONTEND noninteractive

# install supervisord and some additional tools
RUN apt-get update && apt-get upgrade -y
RUN apt-get install -y supervisor \
        net-tools nano apt-utils wget rsyslog

# install postfix
RUN apt-get install -y postfix sasl2-bin

ADD config/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
ADD scripts/init.sh /init.sh
ADD scripts/postfix.sh /postfix.sh
RUN chmod 755 /init.sh

RUN apt-get clean

EXPOSE 25
ENTRYPOINT ["/init.sh"]
CMD ["app:start"]

