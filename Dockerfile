FROM ruby:2.6.3

WORKDIR /app

#RUN curl https://get.helm.sh/helm-v3.1.0-linux-amd64.tar.gz --output helm_bin.tar.gz
#RUN tar -zxvf helm_bin.tar.gz
#RUN mv linux-amd64/helm /usr/local/bin
#RUN rm helm_bin.tar.gz
#RUN rm -rf linux-amd64

RUN gem install bundler:2.1.4
COPY Gemfile Gemfile.lock ./
RUN bundle install
COPY . .

ENTRYPOINT ["/app/docker-entry.sh"]