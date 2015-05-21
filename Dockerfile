FROM lokalebasen/rubies:2.2.0
MAINTAINER Martin Neiiendam mn@lokalebasen.dk
ENV REFRESHED_AT 2015-05-21

WORKDIR /var/www/location_geo_validator/current

ENV ETCD_ENV location_geo_validator
ENV APP_PATH /var/www/location_geo_validator/current

ADD Gemfile /var/www/location_geo_validator/current/Gemfile
ADD Gemfile.lock /var/www/location_geo_validator/current/Gemfile.lock

RUN bundle install --deployment             && \
    mkdir -p /var/log/location_geo_validator

ENV BUNDLE_GEMFILE /var/www/location_geo_validator/current/Gemfile
ADD build.tar /var/www/location_geo_validator/current

CMD ["bundle", "exec", "rake", "validate:coordinates"]
