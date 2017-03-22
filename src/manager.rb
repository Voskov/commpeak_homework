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

  def display_tickets(a)
    grouped = a.group_by{|t| t[0]}.values
    columns = %w(TicketID Requester Status Subject Content)
    head = '<html>
              <head>
                <meta name="viewport" content="width=device-width, initial-scale=1" />
                <link rel="stylesheet" href="https://code.jquery.com/mobile/1.4.5/jquery.mobile-1.4.5.min.css" />
                <script src="https://code.jquery.com/jquery-1.11.3.min.js"></script>
                <script src="https://code.jquery.com/mobile/1.4.5/jquery.mobile-1.4.5.min.js"></script>
                <style>
                    th {
                        border-bottom: 1px solid #d6d6d6;
                    }

                    tr:nth-child(even) {
                        background: #e9e9e9;
                    }
                </style>
              </head>
            '
    thead = "<thead>\n<tr>" << columns.map do |column|
      "<th>#{column}</th>\n"
    end.join(" ") << "</tr>\n</thead>"
    thead
    source = grouped.map do |portion|
      '<body>
          <div data-role="main" class="ui-content">
               <form>
                  <input id="filterTable-input" data-type="search" placeholder="Search For Customers..." />
               </form>
               <table data-role="table" data-mode="columntoggle" class="ui-responsive ui-shadow" id="myTable" data-filter="true" data-input="#filterTable-input">' << thead << "\n<tr>" << portion.map do |column|
        "<td>" << column.map do |element|
          element[1].to_s
        end.join("</td><td>") << "</td>"
      end.join("</tr>\n<tr>") << "</tr>\n</table>\n"
    end.join("") << "\n</div>\n</body>\n</html>\n"
    source = head + source
    # doc = REXML::Document.new(source)
    # formatter = REXML::Formatters::Pretty.new
    # formatter.compact = true
    tmp_file = "output.html"    # TODO - do something with this blasphemy
    # html = ''
    # formatter.write(doc, html)

    output = open(tmp_file, "w")
    output.write(source)
    output.close
    system("start #{output.path}")
    sleep 1
    # File.delete(tmp_file)

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