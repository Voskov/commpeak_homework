require 'user'
require 'db_connector/tickets_db_connector'

class Manager < User
  def initialize(name, email, password)
    super(name, email, :manager, password)
  end

  @@ticket_db_connector = TicketsDbConnector.new

  def display_all_tickets
    all_tickets = @@ticket_db_connector.return_all_tickets
    all_tickets
  end

  def manager_menu
    puts "Manager menu"
    puts "____________"
    puts "1. Show all tickets"
    puts "q. quit - quit the manager menu"
    user_option = nil
    until user_option == "q" || user_option == "quit"
      puts "Please choose an option"
      user_option = $stdin.gets.chomp
      options = %w(1 2 3 4 q quit)
      until options.include? user_option
        puts "One of the options above please"
        user_option = $stdin.gets.chomp
      end
      case
        when "1"
          display_all_tickets
      end
    end
  end
end