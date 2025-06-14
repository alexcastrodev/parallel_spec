FROM ruby:3.2
WORKDIR /app
COPY . .
RUN gem install bundler && bundle install
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]
