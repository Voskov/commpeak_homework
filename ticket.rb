$:.unshift(File.dirname(__FILE__))
require 'time'
require 'CSV'
require 'json'
require 'requester'
require 'user'
require 'db_connector/tickets_db_connector'

class Ticket
  attr_accessor :requester, :subject, :content, :created_at, :updated_at, :status, :id, :comment
  @@csv_file_path = File.join(File.dirname(File.path(__FILE__)), "csv_tickets", "tickets.csv")
  @@ticket_db_connector = TicketsDbConnector.new
  @@ticket_logger = Logger.new(STDOUT)


  def self.get_next_id
    begin
      id = CSV.read(@@csv_file_path)[1..-1].map { |tkt| tkt[0].to_i }.max + 1
    rescue
      id = 1
    end
    return id
  end

  def initialize(requester, subject, content, created_at, updated_at, status = :new, id = nil, comment = nil)
    @requester = requester
    @subject = subject
    @content = content
    @status = status
    @id = id || Ticket.get_next_id
    @created_at = created_at
    @updated_at = updated_at
    @comment = comment
  end

  def update_ticket(subject:nil, content:nil, status:nil, comment:nil)
    @subject = subject if subject
    @content = content if content
    @status = status if status
    @comment = comment if comment
    @updated_at = Time.now.utc.iso8601
    # Yeah, I could have replaced the row, but I already had these lying around, so...
    delete_from_csv
    add_to_csv
  end

  def self.create_new_ticket(requester)
    puts "creating ticket" #TODO - log
    puts "What's the subject of the ticket?"
    subject = $stdin.gets.chomp
    puts "And what's the content? What would you like to report?"
    content = $stdin.gets.chomp
    status = :new
    id = get_next_id
    created_at = Time.now.utc.iso8601
    updated_at = created_at
    ticket = Ticket.new(requester, subject, content, created_at, updated_at, status, id)
    ticket.add_to_csv
    return ticket
  end

  def self.get_ticket_by_id(id)
    all_tickets = CSV.read(@@csv_file_path)[1..-1]
    ticket_arr = all_tickets.detect { |i| i[0].to_i == id }
    requester = Requester.new(JSON.parse(ticket_arr[1])['name'], JSON.parse(ticket_arr[1])['email'])
    ticket = Ticket.new(requester = requester,
                        subject = ticket_arr[3],
                        content = ticket_arr[4],
                        created_at = ticket_arr[5],
                        updated_at= ticket_arr[6],
                        status = ticket_arr[2],
                        ticket_arr[0])
    return ticket
  end

  def delete_from_csv
    table = CSV.table(@@csv_file_path)
    table.delete_if do |row|
      row[:id].to_s == @id
    end
    File.open(@@csv_file_path, "w") do |f|
      f.write(table.to_csv)
    end
  end

  def add_to_csv
    unless File.exists?(@@csv_file_path)
      create_csv_file
    end
    CSV.open(@@csv_file_path, "a") do |csv|
      csv << [@id, @requester.to_json, @status, @subject, @content, @created_at, @updated_at, @comment]
    end
  end

  def create_csv_file
    if File.exists?(@@csv_file_path)
      raise Exception 'csv file already exists'
    end
    CSV.open(@@csv_file_path, 'w') do |csv|
      csv << %w(id requester status subject content created_at updated_at comment)
    end
  end

  def self.count_tickets_by_param(param, value)
    @@ticket_db_connector.count_by_param(param, value)
  end
end