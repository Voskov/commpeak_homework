$:.unshift(File.dirname(__FILE__))
require 'logger'
require 'requester'
require 'ticket'
require 'db_connector/csv_import'
require 'db_connector/db_connector'

# require 'optparse'
# options = {command: nil, params: nil}
# parser = OptionParser.new do |opts|
#   opts.banner = "Usage: main.rb [command] [parameters]"
#   opts.on('-c', '--command comand', 'Command') do |command|
#     options[:command] = command
#   end
#   opts.on
# end

class Main
  def initialize
    @logger = Logger.new(STDOUT)
    @logger.level = Logger::DEBUG
    @user = nil
  end

  def create_ticket
    @logger.debug("creating a ticket")
    unless @user
      @user = User.login
    end
    ticket = Ticket.create_new_ticket(@user)
  end

  def create_user
    User.create_new_user
  end

  def dump_csv_to_db
    puts "dumping"
    csvi = CsvImport.new
    csvi.dump_tickets_to_db
  end

  def initiate
    dbc = DbConnector.new
    dbc.create_db
    dbc.create_tables
  end
end
main = Main.new

puts "Options:"
puts "1. ticket - Create ticket"
puts "2. user - Create user"
puts "3. dump - Cump csv to database"
puts "4. initiate - Initiate the database for this project"
puts "q. quit - quit the program"

user_option = nil
until user_option == "q" || user_option == "quit"
  puts "Please choose an option"
  user_option = gets.chomp
  options = %w(1 2 3 4 q ticket user dump initiate quit)
  until options.include? user_option
    puts "One of the options above please"
    user_option = gets.chomp
  end
  case user_option
    when "1", "ticket"
      main.create_ticket
    when "2", "user"
      main.create_user
    when "3", "dump"
      main.dump_csv_to_db
    when "4", "initiate"
      main.initiate
    when "q", "quit"
      puts "KTXBAI"
  end
end