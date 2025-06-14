require 'sinatra/base'
require 'sinatra/activerecord'
require 'json'
require_relative '../models/user'
require_relative '../models/post'
require_relative '../models/comment'

class App < Sinatra::Base
  register Sinatra::ActiveRecordExtension

  get '/' do
    'OK'
  end

  post '/users' do
    data = JSON.parse(request.body.read)
    user = User.create!(name: data['name'])
    content_type :json
    status 201
    user.to_json
  end

  post '/posts' do
    data = JSON.parse(request.body.read)
    post = Post.create!(user_id: data['user_id'], title: data['title'], body: data['body'])
    content_type :json
    status 201
    post.to_json
  end

  post '/comments' do
    data = JSON.parse(request.body.read)
    comment = Comment.create!(post_id: data['post_id'], body: data['body'])
    content_type :json
    status 201
    comment.to_json
  end
end
