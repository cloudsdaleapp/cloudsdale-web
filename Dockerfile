FROM ruby:2.0.0-p598
MAINTAINER Philip Vieira <zeeraw@cloudsdale.org>

ENV APP_HOME /usr/src/cloudsdale-web
ENV DEBIAN_FRONTEND noninteractive

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

# Create application home and make sure the current repository is added
RUN mkdir -p $APP_HOME
ADD . $APP_HOME
WORKDIR $APP_HOME

# Create an entrypoint for docker
COPY ./entrypoint.sh /
RUN chmod 0755 /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

# Run unicorn server using the configuration file inside the project
CMD ["bundle", "exec", "unicorn_rails", "-c", "$APP_HOME/config/unicorn.rb"]