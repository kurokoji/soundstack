require 'mongoid'
require 'securerandom'
require 'digest'
require 'bcrypt'

Name = 'Users'
Client = Mongo::Client.new(['127.0.0.1:27017'], :database => 'user')
Collection = Client[Name]
enable :sessions

def sign_up(user_name, pass) 
  salt = BCrypt::Engine.generate_salt
  pass_digest = BCrypt::Engine.hash_secret(pass, salt)

  if Collection.find(username: user_name).count != 0
    puts 'failed'
    return false
  end

  new_user = {username: user_name, password: pass_digest, salt: salt}
  Collection.insert_one(new_user)
  return true
end

def sign_in(user_name, pass)
  salt = ''
  digest = ''

  if Collection.find(username: user_name).count == 0
    return false
  end

  Collection.find(username: user_name).each {|doc|
    salt = doc[:salt]
    digest = doc[:password]
  }

  if digest == BCrypt::Engine.hash_secret(pass, salt)
    return true
  end

  return false
end

=begin
Mongoid.load!('./mongoid.yml')

class User
  include Mongoid::Document

  def make_salt(n)
    return SecureRandom.base64(n)
  end

  def register(name, pass)
    salt = make_salt(20)
    digest = Digest::SHA256.digest(pass + salt)
    if find('username' => name).count != 0
      puts 'failed'
      return false
    end

    new_user = {'username': name, 'password': digest, 'salt': salt}
    insert_one(new_user)
    return true
  end
end
=end
