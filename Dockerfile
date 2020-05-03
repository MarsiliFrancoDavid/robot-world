FROM ruby:2.6.6
RUN apt-get update && apt-get install -y \
  curl \
  build-essential \
  libpq-dev &&\
  curl -sL https://deb.nodesource.com/setup_10.x | bash - && \
  curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
  echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
  apt-get update && apt-get install -y nodejs yarn

RUN mkdir /robot-world
WORKDIR /robot-world
COPY Gemfile /robot-world/Gemfile
COPY Gemfile.lock /robot-world/Gemfile.lock
RUN bundle install
RUN yarn install
COPY . /robot-world

# Start the main process.
CMD ["rails", "server", "-b", "0.0.0.0"]