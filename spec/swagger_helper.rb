require 'rswag/specs'

RSpec.configure do |config|
  config.swagger_root = File.expand_path('../swagger', __dir__)
  config.swagger_docs = {
    'v1/swagger.yaml' => {
      openapi: '3.0.1',
      info: { title: 'API V1', version: 'v1' },
      paths: {}
    }
  }
  config.swagger_format = :yaml
end
