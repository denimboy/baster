#!/usr/bin/env ruby

require 'rubygems'
require 'data_mapper'
require 'haml'
require 'sinatra'
require "sinatra/config_file"

config_file 'config.yml'

DataMapper::Logger.new($stdout, :debug)
DataMapper.setup(:default, 'sqlite:///tmp/baseter.db')

# external is our target database
#DataMapper.setup(:external, settings.external)
DataMapper.setup(:external, 'sqlite:///tmp/baseter.db')

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
  @rows = []
  begin
    @rows = repository(:external).adapter.select(@baste.body) # returns list of structs
  rescue
    Error = Struct.new(:message)
    @rows = [ Error.new('An error occured') ]
  end
  @cols = @rows[0].members
  haml :show
end
