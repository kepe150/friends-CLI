require 'sqlite3'

@options = {}
@arguments = []
@friends_database = SQLite3::Database.new "friends_database.db"

#friend_name,hobby,favorite_food,birth
@friends_database.execute <<-SQL
  CREATE TABLE IF NOT EXISTS users (
    id INTEGER PRIMARY KEY,
    name TEXT,
    hobby TEXT,
    favorite_food TEXT,
    birthday TEXT
  );
SQL

ARGV.each do | arg |
  if arg.start_with?("-") || arg.start_with?("@")
    @arguments << arg
  else
    @arguments[-1] += " #{arg}"
  end
end

def process_options(option)
  case option
  when "-list"
    @options[:list] = true
  when "-add"
    @options[:add_friend] = true
  when "-h"
    @options[:help] = true
  end
end

if ARGV == []
  puts 'Preciso de alguma variavel!'
else
  ARGV.each do |option|
    process_options(option)
  end

  if @options == {}
    p "Preciso de alguma tag!"
  end
end

if @options[:list] == true
  puts "ID | Nome | Hobby | Comida favorita | Aniversário"
  @friends_database.execute "SELECT * FROM users" do |row|
    puts row.join(" | ")
  end
end

if @options[:add_friend] == true
  @friend = {}
  @arguments.each do |tag|
    case 
    when tag.start_with?('@name:')
      @friend[:friend_name] = tag.sub('@name:', '')
    when tag.start_with?('@hobby:')
      @friend[:hobby] = tag.sub('@hobby:', '')
    when tag.start_with?('@food:')
      @friend[:favorite_food] = tag.sub('@food:', '')
    when tag.start_with?('@birthday:')
      @friend[:birthday] = tag.sub('@birthday:', '')
    end
    
  end

  @friends_database.execute "INSERT INTO users (name, hobby, favorite_food, birthday) VALUES (?, ?, ?, ?)", [@friend[:friend_name], @friend[:hobby], @friend[:favorite_food], @friend[:birthday]]
  puts "O amigo: #{@friend[:friend_name]} foi adicionado!"
end

if @options[:help] == true
  
  puts "Bem vindo ao Friends Manager CLI - 🤯" 
  puts "  - Tenha seus amigos na palma da mão!"
  puts " "
  puts " > Use '-add' para adicionar com amigos ao banco de dados"
  puts "   - Coloque as tags: @name: , @hobby:, @food: , @birthday: "
  puts "   - Coloque as informações apos os dois pontos"
  puts " "
  puts " > Use '-list' para listar seus amigos "
end
