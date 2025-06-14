# frozen_string_literal: true

require 'active_support/core_ext/integer/time'
Rails.application.configure do
  config.cache_classes = true
  config.eager_load = true
  config.cache_store = :memory_store
  config.action_controller.perform_caching = true
end
