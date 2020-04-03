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
	# создаем таблицу для комментов
	@db.execute 'create table if not EXISTS Comments (id INTEGER PRIMARY KEY AUTOINCREMENT,
	created_date DATE, content TEXT, post_id INTEGER)'
end
get '/' do
	#erb "Hello! <a href=\"https://github.com/bootstrap-ruby/sinatra-bootstrap\">Original</a> pattern has been modified for <a href=\"http://rubyschool.us/\">Ruby School</a>"			
	# выбираем посты из БД
	@results = @db.execute 'select * from Posts order by id desc'
	erb :index
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
	# Сохраняем данные в БД
	@db.execute 'insert into Posts (content, created_date) values (?, datetime())', [content]

	# переход на главную страницу
	redirect to '/'
	# чтоб возвращалось на главную, ранее было: erb "you typed #{content}"
end

# выводим каждый пост на экран для коммента:
get '/details/:post_id' do
	# получаем переменную из url'a
	post_id = params[:post_id]
	# получаем список постов, выбираем один
	results = @db.execute 'select * from Posts where id = ?', [post_id]
	# добавляем этот поств в переменную @row
	@row = results[0]
	#erb "Displaying information for post with id #{post_id}"
	# выбираем комменты для каждого поста
	@comments = @db.execute 'select * from Comments where post_id = ? order by id', [post_id] 
	# передаем это на страницу details.erb
	erb :details
end	
post '/details/:post_id' do		
	# пишем обработку для post-коммента /details/=> браузер отправляет коммент на сервер
		post_id = params[:post_id]
		content = params[:content]
#
@db.execute 'insert into Comments
(content, created_date, post_id) values (?, datetime(), ?)', [content, post_id]
redirect to('/details/' + post_id)
		#erb "You typed comment #{content} for post #{post_id}" 
end	