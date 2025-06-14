# frozen_string_literal: true

require_relative 'boot'
require 'rails'
require 'active_model/railtie'
require 'active_job/railtie'
require 'active_record/railtie'
require 'action_controller/railtie'
Bundler.require(*Rails.groups)

module ParallelSpec
  class Application < Rails::Application
    config.load_defaults 8.0
    config.eager_load = false
    config.api_only = true
    config.cache_store = :memory_store
  end
end
