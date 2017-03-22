class Display
  def display_tickets(result, by_status = nil)
    grouped = result.group_by { |t| t[0] }.values
    columns = %w(TicketID Requester Status Subject Content)
    status_table = by_status ? "<table>\n" + status_table(by_status) : "\n"
    head = tickets_head
    thead = table_header(columns)
    end_str = "\n</div>\n</body>\n</html>\n"
    start = '<body>
          <div data-role="main" class="ui-content">
               <form>
                  <input id="filterTable-input" data-type="search" placeholder="Search For Customers..." />
               </form>
               <table data-role="table" data-mode="columntoggle" class="ui-responsive ui-shadow" id="myTable" data-filter="true" data-input="#filterTable-input">'


    tickets_table = start << table_body(grouped, thead) << end_str
    source = head + status_table + tickets_table
    tmp_file = "output.html" # TODO - do something with this blasphemy
    output = open(tmp_file, "w")
    output.write(source)
    output.close
    system("start #{output.path}")
    sleep 1
    File.delete(tmp_file)

  end

  def status_table(by_status)
    grouped = by_status.group_by { |t| t[0] }.values
    columns = ['Status', 'Amount']
    thead = table_header(columns)

    statuses_table = table_body(grouped, thead)
    statuses_table
  end

  def table_body(grouped, thead)
    grouped.map do |portion|
      thead << "\n<tr>" << portion.map do |column|
        "<td>" << column.map do |element|
          element[1].to_s
        end.join("</td><td>") << "</td>"
      end.join("</tr>\n<tr>") << "</tr>\n</table>\n"
    end.join("")
  end

  def table_header(columns)
    "<thead>\n<tr>" << columns.map do |column|
      "<th>#{column}</th>\n"
    end.join(" ") << "</tr>\n</thead>"
  end

  def tickets_head
    '<html>
              <head>
                <title>All Tickets</title>
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
  end
end