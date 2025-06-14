# frozen_string_literal: true

require 'active_support/core_ext/integer/time'
Rails.application.configure do
  config.cache_classes = false
  config.eager_load = false
  config.cache_store = :memory_store
  config.action_controller.perform_caching = true
end
