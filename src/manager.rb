require 'rexml/document'
require 'logger'
require 'src/user'
require 'display'
require 'db_connector/tickets_db_connector'

class Manager < User
  @@manager_logger = Logger.new(STDOUT)

  def initialize(name, email, password)
    super(name, email, :manager, password)
    @display = Display.new
    @ticket_db_connector = TicketsDbConnector.new
  end


  def display_all_tickets
    all_tickets = @ticket_db_connector.return_all_tickets
    tickets_by_status = @ticket_db_connector.count_by_param('status')
    @display.display_tickets(all_tickets, tickets_by_status)
  end

  def dump_csv_to_db
    @@user_logger.info("dumping csv")
    csvi = CsvImport.new
    csvi.dump_tickets_to_db
  end

  def manager_menu
    puts "Manager menu"
    puts "____________"
    puts "1. Show all tickets"
    puts "2. Dump csv to DB"
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
      case user_option
        when "1"
          display_all_tickets
        when "2"
          dump_csv_to_db
      end
    end
  end
end