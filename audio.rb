require 'sinatra'
require 'sinatra/reloader'
require 'sass'
require 'mongoid'
require 'bcrypt'
require 'date'

name = "Audio"
Client_Audio = Mongo::Client.new(['127.0.0.1:27017'], :database => 'user')
Collection_Audio = Client_Audio[name]

def submit_audio(username, title, description)
  
  id = "%d%02d%02d%02d%02d%02d" % [Time.now.year, Time.now.month, Time.now.day, Time.now.hour, Time.now.min, Time.now.sec]
  in_audio = {username: username, title: title, description: description, audio_id: id}
  Collection_Audio.insert_one(in_audio)
  return id
end

def get_audio_doc(username)
  return Collection_Audio.find(username: username)
end
