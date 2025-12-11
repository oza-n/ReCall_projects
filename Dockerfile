FROM ruby:3.3.6

ENV LANG C.UTF-8
ENV TZ Asia/Tokyo

RUN  apt-get update -qq && \
        apt-get install -y nodejs postgresql-client && \
        apt-get clean && \
        rm -rf var/lib/apt/list/*

WORKDIR /app

COPY Gemfile Gemfile.lock ./
RUN bundle install
COPY . .

CMD ["rails", "server", "-b", "0.0.0.0"]
