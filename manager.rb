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
end