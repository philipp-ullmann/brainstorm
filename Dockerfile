FROM ruby:2.4.0-alpine

RUN     mkdir -p /root/brainstorm
WORKDIR /root/brainstorm

# ADD SOURCE CODE
COPY app app
COPY bin bin
COPY config config
COPY db db
COPY lib lib
COPY public public
COPY doc doc
COPY spec spec
ADD config.ru Rakefile Gemfile Gemfile.lock ./

# INSTALL DEPENDENCIES
RUN apk --update --upgrade add tzdata build-base mysql-dev && \
    
    # Set timezone
    TZ=Europe/Vienna && \
    cp /usr/share/zoneinfo/$TZ /etc/localtime && \
    echo $TZ > /etc/timezone && \

    # Install gems
    echo 'gem: --no-rdoc --no-ri' >> /root/.gemrc && \
    bundle install && \
    
    # Cleanup
    rm -rf /tmp/* /var/cache/apk/*

# START SERVER
EXPOSE 3000
CMD ["/root/brainstorm/bin/start.sh"]
