FROM ruby:3.2
WORKDIR /app
COPY . .
RUN gem install bundler && bundle install
CMD ["ruby", "app/app.rb", "-p", "4567", "-o", "0.0.0.0"]
