require 'sinatra'
require 'sinatra/reloader'
require 'haml'
require './users.rb'
require './audio.rb'
require 'sass'

get '/sidebar.css' do
  scss :sidebar
end


get '/' do
  @title = 'SoundStack'
  haml :main
end

get '/sign_up' do
  @title = '新規登録'
  # haml :sign_up, :layout => false
  haml :sign_up
end

post '/sign_up' do
  @title = '新規登録'
  user = params[:input_username]
  pass = params[:input_password]

  if user.length < 4
    @isFailed = true
    @sentence = "新規登録に失敗しました．ユーザ名は4文字以上でなければなりません．"
    return haml :sign_up
  end

  if pass.length < 8
    @isFailed = true
    @sentence = "新規登録に失敗しました．パスワードは8文字以上でなければなりません．"
    return haml :sign_up
  end

  if !sign_up(user, pass)
    @isFailed = true
    @sentence = "新規登録に失敗しました．ユーザ名が既に使われています"
    return haml :sign_up
  end
  redirect to('/')
end

get '/sign_in' do
  @title = "サインイン"
  if session[:user_id]
    redirect to('/')
  end

  haml :sign_in
end

post '/sign_in' do
  @title = "サインイン"
  user = params[:input_username]
  pass = params[:input_password]

  if session[:user_id]
    redirect to('/')
  end

  if sign_in(user, pass)
    session[:user_id] = user
    redirect to('/')
  else
    @isFailed = true
    @sentence = "サインインに失敗しました．IDかパスワードを確認してください．"
  end

  haml :sign_in
end

get '/sign_out' do
  @title = "サインアウト"
  unless session[:user_id]
    redirect to('/sign_in')
  end

  haml :sign_out
end

delete '/sign_out' do
  @title = "サインアウト"
  session[:user_id] = nil
  redirect to('/sign_in')
end

get '/mypage' do
  unless session[:user_id]
    @title = "サインイン"
    @isFailed = true
    @sentence = "サインインしてください"
    return haml :sign_in
  end
  @title = "マイページ | " + session[:user_id]
  doc = get_audio_doc(session[:user_id])
  @audio_all = []
  puts 'beg'
  doc.each {|audio|
    puts 'hoge'
    @audio_all << audio
  }
  @audio_all.reverse!

  haml :mypage
end

get '/user/:name' do
  @username = params[:name]
  @title = "投稿Sound | " + @username
  doc = get_audio_doc(@username)
  @audio_all = []
  doc.each {|audio|
    @audio_all << audio
  }
  @audio_all.reverse!
  haml :userpage
end


post '/search' do
  username = params[:user]
  redirect ('/user/' + username)
end

get '/mypage/submit' do
  @title = "投稿 | " + session[:user_id]
  haml :submit
end

post '/mypage/submit' do
  @title = "投稿 | " + session[:user_id]
  audio_title = params[:input_title]
  audio_description = params[:input_description]
  params[:input_audio]
  unless params[:input_audio]
    @isFailed = true
    @sentence = "ファイルをアップロードしてください"
    return haml :submit
  end

  if audio_title.length == 0
    @isFailed = true
    @sentence = "タイトルを入力してください"
    return haml :submit
  end

  if audio_description.length == 0
    @isFailed = true
    @sentence = "説明文を入力してください"
    return haml :submit
  end

  id = submit_audio(session[:user_id], audio_title, audio_description)

  save_path = "./public/music/" + id + ".mp3"
  File.open(save_path, 'wb') do |f|
    f.write(params[:input_audio][:tempfile].read)
  end

  redirect to('/mypage')
end


