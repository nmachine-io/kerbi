FROM ruby:2.6.3-alpine3.10

WORKDIR /app

RUN apk --update add build-base libxslt-dev libxml2-dev curl bash git

RUN curl https://get.helm.sh/helm-v3.1.0-linux-amd64.tar.gz --output helm_bin.tar.gz
RUN tar -zxvf helm_bin.tar.gz
RUN mv linux-amd64/helm /usr/local/bin
RUN rm helm_bin.tar.gz
RUN rm -rf linux-amd64

ADD Gemfile Gemfile.lock ./

RUN gem install bundler && \
     bundle config set without 'development' && \
     bundle install --jobs 20 --retry 5

#RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/v1.17.5/bin/linux/amd64/kubectl && \
#    mv kubectl /usr/bin/kubectl && \
#    chmod +x /usr/bin/kubectl

ADD . /app

ENTRYPOINT ["/app/docker-entry.sh"]