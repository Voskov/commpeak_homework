$:.unshift(File.dirname(File.dirname(__FILE__)))
require 'time'
require 'rspec'
Dir["../db_connector/*.rb"].each { |file| require file }
require 'src/ticket'
require 'src/requester'

describe 'Test DbConnector' do
  before(:all) do
    @dbc = DbConnector.new
    @ticket_dbc = TicketsDbConnector.new
    @user_dbc = UserDbConnector.new
    @configs = YAML.load_file(File.join(File.dirname(__FILE__), "..", "config", "config.yaml"))
  end

  it 'create a table' do
    @ticket_dbc.create_tickets_table
  end

  it 'should save a ticket to DB' do
    ticket = Ticket.new(Requester.new("tester", "tester@email.com"), "test subject", "test content", Time.now.utc.iso8601, Time.now.utc.iso8601)
    @ticket_dbc.save_ticket(ticket)
  end

  it 'should save using a prepared statement' do
    ticket = Ticket.create_new_ticket(Requester.new("tester", "tester@email.com"))
    @ticket_dbc.save_ticket_prepared(ticket)
  end

  it 'drops the tickets table' do
    skip
    table = @dbc.configs['DB']['tickets_table']
    @dbc.drop_table(table)
  end

  it 'drops the whole database' do
    @dbc.drop_database('commpeak')
  end

  it 'Should create a database' do
    @dbc.create_db
  end

  it 'should import the CSV to the DB' do
    dumper = CsvImport.new
    dumper.dump_tickets_to_db
  end

  it 'should return user by email' do
    email = "testuser@email.com"
    expected = {"email" => "testuser@email.com", "name" => "test user", "role" => "manager", "password" => "1e09db393d3bafadbbe556d007e8e97bcc459090"}
    res = @user_dbc.get_user_by_email(email)
    expect(res).to eq expected
  end
end