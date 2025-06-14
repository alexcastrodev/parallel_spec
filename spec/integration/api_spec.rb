require 'rack/test'
require 'json'
require_relative '../../app/app'

RSpec.describe 'API', type: :request do
  include Rack::Test::Methods

  def app
    App.new
  end

  describe 'POST /users' do
    it 'creates a user and returns 201 status' do
      user_params = { name: 'John' }.to_json
      header 'Content-Type', 'application/json'
      post '/users', user_params

      expect(last_response.status).to eq(201)
      data = JSON.parse(last_response.body)
      expect(data['name']).to eq('John')
    end
  end
end
