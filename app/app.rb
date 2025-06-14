require 'sinatra/base'
require 'sinatra/activerecord'
require_relative '../models/user'
require_relative '../models/post'
require_relative '../models/comment'

class App < Sinatra::Base
  register Sinatra::ActiveRecordExtension

  get '/' do
    'OK'
  end
end
