require 'swagger_helper'
require_relative '../../app/app'

RSpec.describe 'API', type: :request do
  include Rack::Test::Methods

  def app
    App.new
  end

  path '/users' do
    post 'Creates a user' do
      consumes 'application/json'
      parameter name: :user, in: :body, schema: { type: :object, properties: { name: { type: :string } }, required: ['name'] }

      response '201', 'user created' do
        let(:user) { { name: 'John' } }
        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['name']).to eq('John')
        end
      end
    end
  end
end
