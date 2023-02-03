require "sinatra"
require "sinatra/reloader"
require "SQlite3"
require "bcrypt"
require "slim"

enable :sessions

DB = SQLite3::Database.new("Speldatabas.db")
post "/register" do
  @user = User.new(params[:user])
  if @user.save
    redirect "/login"
  else
    slim :register
  end
end

post "/login" do
  @user = User.find_by(username: params[:username])
  if @user && @user.authenticate(params[:password])
    session[:user_id] = @user.id
    redirect "/reviews"
  else
    slim :login
  end
end

get "/logout" do
  session[:user_id] = nil
  redirect "/"
end

get "/reviews" do
  @reviews = Review.all
  slim :reviews
end

post "/reviews" do
  @review = Review.new(params[:review])
  @review.user_id = session[:user_id]
  if @review.save
    redirect "/reviews"
  else
    slim :new_review
  end
end

get "/search" do
    @games = Game.where("title like ?", "%#{params[:query]}%")
    slim :search
  end