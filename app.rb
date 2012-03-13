#!/usr/bin/env ruby

require 'rubygems'
require 'data_mapper'
require 'haml'
require 'sinatra'

DataMapper::Logger.new($stdout, :debug)
DataMapper.setup(:default, 'sqlite:///tmp/baseter.db')
#DataMapper.setup(:default, 'postgres://localhost/the_database_name')

class Baste
  include DataMapper::Resource
  property :id,         Serial
  property :title,      String
  property :body,       Text
  property :created_at, DateTime
end

DataMapper.finalize
DataMapper.auto_upgrade!

get '/' do
  @bastes = Baste.all(:order => [ :created_at.desc ])
  haml :index
end

get '/new' do
  haml :create
end

post '/new' do
  @baste = Baste.create(
    :title      => params[:title],
    :body       => params[:body],
    :created_at => Time.now
  )
  @baste.save
  redirect '/'
end

get '/show/:baste' do |id|
  @baste = Baste.get(id)
  haml :show
end
