FROM docker.io/ruby:2.7.8

RUN gem install bundler:2.4.22

# throw errors if Gemfile has been modified since Gemfile.lock
RUN bundle config --global frozen 1

WORKDIR /usr/src/app

COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY . .

CMD ["./bin/serve"]
