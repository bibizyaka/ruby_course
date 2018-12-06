require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'

get '/' do
	erb "Hello! <a href=\"https://github.com/bootstrap-ruby/sinatra-bootstrap\">Original</a> pattern has been modified for <a href=\"http://rubyschool.us/\">Ruby School</a>"			
end

get '/about' do
	erb :about
end

get '/visit' do
	erb :visit
end

get '/contacts' do
	erb :contacts
end

#---------------------------------

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

    contacts << "Email: #{@email}, Comment: #{@comments}"
    input = File.open "public/contacts.txt","a"

    input << contacts + "\n"
    input.close

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

   
   erb :thank_you_page

end # contacts


post '/visit' do 
    
    users = ""
    @user_name = params[:username]
    @phone = params[:phone]
    @barber = params[:barber]
    @date = params[:date_t]

    hh = {

    	  :username => "Enter Name", 
          :phone     => "Enter Phone", 
          :date_t    => "Pick Date"
         
         }

    hh.each do |key, value|
         
       if (params[key] == "")
        if (@error)
          @error += value
         return erb :visit
   
        else
      	  @error = value
          return erb :visit
        end
      end #if
    end #each
    
  users << "Name: #{@user_name}, Phone: #{@phone}, Barber: #{@barber}, Date: #{@date}"
  input = File.open "users.txt","a"

  input << users + "\n"
  input.close
   
  erb :thank_you_page

end #/visit

