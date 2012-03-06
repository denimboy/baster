#!/usr/bin/env ruby

require 'rubygems'
require 'data_mapper'
require 'haml'
require 'sinatra'

DataMapper::Logger.new($stdout, :debug)
DataMapper.setup(:default, 'sqlite:///tmp/baseter.db')
#DataMapper.setup(:default, 'postgres://localhost/the_database_name')

class Post
  include DataMapper::Resource
  property :id,         Serial
  property :title,      String
  property :body,       Text
  property :created_at, DateTime
end

DataMapper.finalize
DataMapper.auto_upgrade!

get '/' do
  @posts = Post.all(:order => [ :created_at.desc ])
  haml :index
end

get '/new' do
  haml :create
end

post '/new' do
  @post = Post.create(
    :title      => params[:title],
    :body       => params[:body],
    :created_at => Time.now
  )
  @post.save
  redirect '/'
end

get '/show/:post' do |id|
  @post = Post.get(id)
  haml :show
end
