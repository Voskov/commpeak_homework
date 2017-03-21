require_relative 'db_connector'
require_relative '../ticket'
require_relative 'tickets_db_connector'

class CsvImport < DbConnector
  def dump_tickets_to_db
    drop_table_statement = "DROP TABLE IF EXISTS tickets"
    execute_statement(drop_table_statement)
    TicketsDbConnector.new.create_tickets_table
    stmt = "COPY tickets FROM '#{Ticket.class_variable_get(:@@csv_file_path)}' DELIMITER ',' CSV HEADER"
    execute_statement stmt
  end
end