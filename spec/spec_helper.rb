require 'action_view'
unless ActionView::Template::Handlers::ERB.const_defined?(:ENCODING_FLAG)
  ActionView::Template::Handlers::ERB.const_set(:ENCODING_FLAG, '')
end

require 'rspec/rails'
