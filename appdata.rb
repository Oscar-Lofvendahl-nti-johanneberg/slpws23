require "sinatra"
require "sinatra/reloader"
require "sqlite3"
require "bcrypt"
require "slim"

enable :sessions
db = SQLite3::Database.new("db/Speldatabas.db")

get('/') do 
  slim(:start)
end

get('/games') do
  db = SQLite3::Database.new("db/Speldatabas.db")
  db.results_as_hash = true
  @games = db.execute("SELECT * FROM games")
  p @games

  if session[:id] == nil
    "No access, need to login!"
  else
  slim(:index)
  end
end 

get('/games/new') do

  if session[:id] == nil
    "No access, need to login!"
  else
  slim(:new)
  end
end

post('/games/new') do
  title = params[:title]
  description = params[:description]
  genre = params[:genre]
  format = params[:format]
  rating = params[:rating]
  userid = params[:userid].to_i
  db = SQLite3::Database.new("db/Speldatabas.db")
  db.execute("INSERT INTO games (title, description, genre, format, rating, userid) VALUES (?,?,?,?,?,?)", title, description, genre, format, rating, userid).first
  redirect('/games')
end 

post('games/:id/delete') do
  id = params[:id].to_i
  db = SQLite3::Database.new("db/Speldatabas.db")
  db.execute("DELETE FROM games WHERE gameid = ?", id)
  redirect('/games')
end

post('/games/:id/update') do
  id = params[:id].to_i
  title = params[:title]
  description = params[:description]
  genre = params[:genre]
  format = params[:format]
  rating = params[:rating]
  userid = params[:userid].to_i
  db = SQLite3::Database.new("db/Speldatabas.db")
  db.execute("UPDATE games SET title=?,description=?,genre=?,format=?,rating=?,userid=? WHERE gameid = ?", title, description, genre, format, rating, userid,id)
  redirect('/games')
end

get('games/:id/edit') do
  id = params[:id].to_i 
  db = SQLite3::Database.new("db/Speldatabas.db")
  db.results_as_hash = true
  @edit = db.execute("SELECT * FROM games WHERE gameid = ?",id).first
  p @edit
  slim(:edit)
end

get('/games/:id') do 
  id = params[:id].to_i
  db = SQLite3::Database.new("db/Speldatabas.db")
  db.results_as_hash = true
  @result = db.execute("SELECT * FROM games WHERE gameid = ?",id).first
  p @result
  slim(:show)
end 

get('/login') do
  slim(:login)
end

post('/login') do
  username = params[:username]
  password = params[:password]
  db = SQLite3::Database.new("db/Speldatabas.db")
  db.results_as_hash = true
  user = db.execute("SELECT * FROM users WHERE username = ?", username).first
  check_password = user["password_digest"].to_s
  user_id = user["id"]

  if (BCrypt::Password.new(check_password) == password)
    session[:id] = user_id
    session[:username] = db.execute('SELECT username FROM users WHERE id = ?', session[:id])
    redirect('/games/new')
  else 
    "Invalid username or password"
  end
end

get('/logout') do
  session[:id] = nil
  redirect('/')
end

get('/register') do
  slim(:register)
end

post('/register') do
  username = params[:username]
  password = params[:password]
  password_confirm = params[:password_confirm]
    if (password == password_confirm)
      password_digest = BCrypt::Password.create(password)
      db = SQLite3::Database.new('db/Speldatabas.db')
      db.execute("INSERT INTO users (username,password_digest) VALUES (?, ?)",username, password_digest)
      redirect('/login')
    else 
      "Password did not match!"
    end 
end