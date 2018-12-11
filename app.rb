require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'sqlite3'

def is_barber_exists? db, name
	db.execute('select * from Barbers where name=?', [name]).length > 0
end

def seed_db db, barbers

	barbers.each do |barber|
		if !is_barber_exists? db, barber
			db.execute 'insert into Barbers (name) values (?)', [barber]
		end 
	end

end

def get_db
	db = SQLite3::Database.new 'barbershop.db'
	db.results_as_hash = true
	return db
end

before do
	db = get_db
	@barbers = db.execute 'select * from Barbers'
end

configure do
	db = get_db
	db.execute 'CREATE TABLE IF NOT EXISTS
		"Users"
		(
			"id" INTEGER PRIMARY KEY AUTOINCREMENT,
			"username" TEXT,
			"phone" TEXT,
			"datestamp" TEXT,
			"barber" TEXT,
			"color" TEXT
		)'

	db.execute 'CREATE TABLE IF NOT EXISTS
		"Barbers"
		(
			"id" INTEGER PRIMARY KEY AUTOINCREMENT,
			"name" TEXT
		)'

	seed_db db, ['Jessie Pinkman', 'Walter White', 'Gus Fring', 'Mike Ehrmantraut']

	db.execute 'CREATE TABLE IF NOT EXISTS
		"Contacts"
		(
			"id" INTEGER PRIMARY KEY AUTOINCREMENT,
			"email" TEXT,
			"message" TEXT
		)'

end

get '/' do
	erb "Hello! <a href=\"https://github.com/bootstrap-ruby/sinatra-bootstrap\">Original</a> pattern has been modified for <a href=\"http://rubyschool.us/\">Ruby School</a>"			
end

get '/about' do
	erb :about
end

get '/visit' do
	erb :visit
end

post '/visit' do

	@username = params[:username]
	@phone    = params[:phone]
	@datetime = params[:datetime]
	@barber   = params[:barber]
	@color    = params[:color]

	# хеш
	hh = { 	:username => 'Введите имя',
			:phone    => 'Введите телефон',
			:datetime => 'Введите дату и время' }

	@error = hh.select {|key,_| params[key] == ""}.values.join(", ")

	if @error != ''
		return erb :visit
	end

	db = get_db
	db.execute 'insert into
		Users
		(
			username,
			phone,
			datestamp,
			barber,
			color
		)
		values (?, ?, ?, ?, ?)', [@username, @phone, @datetime, @barber, @color]

	erb "OK, username is #{@username}, #{@phone}, #{@datetime}, #{@barber}, #{@color}"

end

get '/contacts' do
	erb :contacts
end

post '/contacts' do

    contacts = ""
    @email = params[:email]
    @comments = params[:comments]

	hh = { :email    => "Provide your email",
	       :comments => "Enter your comment"
	     }

    hh.each do |key, value|

       if params[key] == ""

          @error = value 
          return erb :contacts
       
       end
    end

    # contacts << "Email: #{@email}, Comment: #{@comments}"
    # input = File.open "public/contacts.txt","a"

    # input << contacts + "\n"
    # input.close

	db = get_db
	db.execute 'insert into
		Contacts
		(
			email,
			message
		)
		values (?, ?)', [@email, @message]

#--------------send email ----------------------
require 'pony'

Pony.mail(

 # :name => params["suslik"],
 # :mail => params[:email],
 # :body => params[:comments],
  :to   => 'gbmatrix@gmail.com',
  :subject => params[:email] + " has contacted you",
  :body => params[:comments],
  :via  => :smtp,
  :via_options => { 
    :address              => 'smtp.gmail.com', 
    :port                 => '587', 
    :enable_starttls_auto => true, 
    :user_name            => 'gbmatrix', 
    :password             => 'mozudhuwrvblbwmt', 
    :authentication       => :plain, 
    :domain               => 'localhost.localdomain'
  })
#redirect '/success' 
   
   erb "Thank you, your mail was sent..."

end # contacts


get '/showusers' do
	db = get_db

	@results = db.execute 'select * from Users order by id desc'

	erb :showusers
end

