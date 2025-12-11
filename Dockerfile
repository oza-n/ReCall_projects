FROM ruby:3.3.6

ENV LANG C.UTF-8
ENV TZ Asia/Tokyo

RUN  curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
        apt-get update -qq && \
        apt-get install -y nodejs postgresql-client && \
        npm install -g yarn && \
        apt-get clean && \
        rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY . .

CMD ["rails", "server", "-b", "0.0.0.0"]
