require "./config/environment"
require "./app/models/user"
class ApplicationController < Sinatra::Base

  configure do
    set :views, "app/views"
    enable :sessions
    set :session_secret, "password_security"
  end

  get "/" do
    erb :index
  end

  get "/signup" do
    erb :signup
  end

  post "/signup" do
    #your code here
    if params[:username] != ""
      user = User.new(username: params[:username], password: params[:password])
      if user.save
        redirect "/login"
      else
        redirect "/failure"
      end
    else
      redirect "/failure"
    end
  end

  get '/account' do
    if logged_in?
      @user = current_user
      erb :account
    else
      redirect "/failure"
    end
  end

  post '/account' do
    user = current_user
    puts params
    new_balance = user.balance + params[:deposit].to_i
    if new_balance >= params[:withdrawel].to_i
      new_balance -= params[:withdrawel].to_i
      user.balance = new_balance
      user.save
      redirect "/account"
    else
      redirect "/deposit_error"
    end
  end

  get '/deposit_error' do
    @user = current_user
    erb :deposit_error
  end

  get "/login" do
    erb :login
  end

  post "/login" do
    ##your code here
    user = User.find_by(username: params[:username])
    if params[:username] != "" && user
      if user.authenticate(params[:password])
        session[:user_id] = user.id 
        redirect "/account"
     else
        redirect "/login"
      end
    else
        redirect "/failure"
    end
  end

  get "/failure" do
    erb :failure
  end

  get "/logout" do
    session.clear
    redirect "/"
  end

  helpers do
    def logged_in?
      !!session[:user_id]
    end

    def current_user
      User.find(session[:user_id])
    end
  end

end
