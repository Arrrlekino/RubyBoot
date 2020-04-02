#encoding: utf-8
require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'sqlite3'

def init_db
	@db = SQLite3::Database.new 'rubyboot.db'
	@db.results_as_hash = true
end
before do
	init_db
end	
# configure ввызывается каждый раз при конфигурации приложения:
# инициализация БД когда меняем код пр-мы или перезагрузилась страница
configure do
	# инициализация БД
	init_db
	# создает таблицу если такой не существует
	@db.execute 'CREATE TABLE IF NOT EXISTS Posts
	(id INTEGER PRIMARY KEY AUTOINCREMENT, created_date DATE, content TEXT
	)'
end
get '/' do
	erb "Hello! <a href=\"https://github.com/bootstrap-ruby/sinatra-bootstrap\">Original</a> pattern has been modified for <a href=\"http://rubyschool.us/\">Ruby School</a>"			
end
# обработка get-запрса /new => браузер получает страницу с сервера
get '/new' do
erb	:new
end	
#get '/new' do
 # "Hello World"
#end
# обработка post-запрса /new => браузер отправляет страницу на сервер
post '/new' do
	# получаем переменную из post-запрса
	content = params[:content]
	if content.length <= 0
		@error = 'Type text'
		return erb :new
	end	
	erb "you typed #{content}"
end