# Parallel Spec Example

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

Enter the development container or run the following command to start the web service in a terminal:

```bash
docker compose run -it --rm web bash
```


1. Install Ruby dependencies:

   ```bash
   bundle install
   ```

2. Create the test databases and load the schema:

   ```bash
   for i in 1 2 3 4; do TEST_ENV_NUMBER=$i bundle exec rake db:create; done
   ```

3. Start the service stack:

   ```bash
   bundle exec parallel_rspec -n 2 spec
   ```

Each example truncates its tables, flushes its Redis database, and recreates OpenSearch indexes so specs do not interfere with each other.

Integration tests are written using RSwag. To generate the Swagger document run:

```bash
bundle exec rake rswag:specs:swaggerize
```