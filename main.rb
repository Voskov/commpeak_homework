$:.unshift(File.dirname(__FILE__))
require 'logger'
require 'src/requester'
require 'src/manager'
require 'src/ticket'
require 'db_connector/csv_import'
require 'db_connector/db_connector'

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

  def print_options
    puts "Options:"
    puts "1. ticket - Create ticket"
    puts "2. user - Create user"
    puts "3. initiate - Initiate the database for this project"
    puts "4. manager - manager menu"
    puts "5. logout - Logs the current user out"
    puts "q. quit - quit the program"
  end

  def create_user
    User.create_new_user
  end

  def logout
    @logger.info("logging out")
    @user = nil
  end

  def manager_menu
    unless @user
      @user = User.login
    end
    if @user.is_a? Manager
      @user.manager_menu
    else
      puts "Sorry, the current user isn't a manager"
      print_options
    end
  end

  def initiate
    dbc = DbConnector.new
    dbc.create_db
    dbc.create_tables
  end

  def main
    print_options
    user_option = nil
    until user_option == "q" || user_option == "quit"
      puts "Please choose an option"
      user_option = $stdin.gets.chomp
      options = %w(1 2 3 4 5 q ticket user initiate manager logout quit)
      until options.include? user_option
        puts "One of the options above please"
        user_option = $stdin.gets.chomp
      end
      case user_option
        when "1", "ticket"
          create_ticket
        when "2", "user"
          create_user
        when "3", "initiate"
          initiate
        when "4", "manager"
          manager_menu
        when "5", "logout"
          logout
        when "q", "quit"
          puts "KTXBAI"
      end
    end
  end
end
Main.new.main
