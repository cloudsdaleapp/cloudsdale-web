FROM ruby:2.0.0-p598
MAINTAINER Philip Vieira <zeeraw@cloudsdale.org>

ENV GEM_HOME /gems/2.0
ENV BUNDLE_PATH $GEM_HOME
ENV BUNDLE_APP_CONFIG $GEM_HOME

RUN gem install bundle

# Install GeoIP City
RUN \
  apt-get update -y && \
  apt-get install -y libgeoip-dev && \
  curl -L http://geolite.maxmind.com/download/geoip/database/GeoLiteCity.dat.gz > GeoLiteCity.dat.gz && \
  gzip -d GeoLiteCity.dat.gz && \
  mkdir -p /usr/local/share/GeoIP/ && \
  mv GeoLiteCity.dat /usr/local/share/GeoIP/

# Install ImageMagick dependencies
RUN curl -L http://www.imagemagick.org/download/ImageMagick.tar.gz > ImageMagick.tar.gz
RUN tar -xvzf ImageMagick.tar.gz
RUN cd ImageMagick-* && ./configure && make && make install

# Install GraphicsMagick dependencies
RUN curl -L http://ftp.icm.edu.pl/pub/unix/graphics/GraphicsMagick/GraphicsMagick-LATEST.tar.gz > GraphicsMagick.tar.gz
RUN tar -xvzf GraphicsMagick.tar.gz
RUN cd GraphicsMagick-* && ./configure && make && make install

ADD . /var/www/www.cloudsdale.org/
WORKDIR /var/www/www.cloudsdale.org/

EXPOSE 8080
CMD ["./bin/unicorn_rails", "-c", "/var/www/www.cloudsdale.org/config/unicorn.rb"]