require 'logger'
require 'user'
require 'db_connector/tickets_db_connector'

class Manager < User
  @@manager_logger = Logger.new(STDOUT)
  def initialize(name, email, password)
    super(name, email, :manager, password)
  end

  @@ticket_db_connector = TicketsDbConnector.new

  def display_all_tickets
    all_tickets = @@ticket_db_connector.return_all_tickets
    display_tickets(all_tickets)
  end

  def display_tickets(a)
    grouped = a.group_by{|t| t[0]}.values
    columns = %w(ID Requester Status Subject Content)
    header = "<tr>" << columns.map do |column|
      "<td>#{column}</td>"
    end.join(" ") << "</tr>"
    header
    table = grouped.map do |portion|
      "<table border=\"1\">\n" << header << "\n<tr>" << portion.map do |column|
        "<td>" << column.map do |element|
          element[1].to_s
        end.join("</td><td>") << "</td>"
      end.join("</tr>\n<tr>") << "</tr>\n</table>\n"
    end.join("\n")
    tmp_file = "output.html"

    output = open(tmp_file, "w")
    output.write(table)
    output.close
    system("start #{output.path}")
    sleep 1
    File.delete(tmp_file)

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