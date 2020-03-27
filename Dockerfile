FROM ruby:2.5

RUN gem install bundler -v 2.0.2

ADD Gemfile /tmp/Gemfile
ADD Gemfile.lock /tmp/Gemfile.lock
RUN (cd /tmp && bundle install)

WORKDIR /app
EXPOSE 4567

ADD . /app

CMD [ "bundle", "exec", "ruby", "app.rb", "-o", "0.0.0.0"]
