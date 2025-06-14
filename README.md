# Parallel Spec Example

[![codecov](https://codecov.io/gh/<user>/<repo>/branch/main/graph/badge.svg)](https://codecov.io/gh/<user>/<repo>)

This project demonstrates a Sinatra application using ActiveRecord, Redis and OpenSearch with Searchkick. Tests are written with RSpec and can be executed in parallel.

## Services

`docker-compose.yml` provides the following containers:

- **db**: PostgreSQL
- **redis**: Redis
- **opensearch**: OpenSearch
- **web**: Sinatra application

## Dev Container

Open this repository with VS Code and the Dev Containers extension to get a ready-to-use environment. The configuration is under `.devcontainer/` and relies on `docker-compose.yml` to start all services.

## Running Tests in Parallel

1. Install Ruby dependencies:

   ```bash
   bundle install
   ```

2. Create the test databases and load the schema:

   ```bash
   bundle exec rake db:create db:migrate
   bundle exec rake parallel:create
   bundle exec rake parallel:prepare
   ```

3. Start the service stack:

   ```bash
   docker-compose up -d
   ```

4. Execute specs in parallel (two processes in this example):

   ```bash
   DB_HOST=localhost DB_PASSWORD=password \
   REDIS_URL_BASE=redis://localhost:6379 \
   bundle exec parallel_rspec -n 2 spec
   ```

Each example truncates its tables, flushes its Redis database, and recreates OpenSearch indexes so specs do not interfere with each other.

Integration tests are written using RSwag. To generate the Swagger document run:

```bash
bundle exec rake rswag:specs:swaggerize
```

## Code Coverage

This project uses [SimpleCov](https://github.com/simplecov-ruby/simplecov) with the
[Codecov](https://about.codecov.io/) formatter. When tests are run, a coverage
report is generated in `coverage/`. When running in CI with the `CODECOV_TOKEN`
environment variable set, the results can be uploaded to Codecov:

```bash
CODECOV_TOKEN=your-token bundle exec rspec
```
