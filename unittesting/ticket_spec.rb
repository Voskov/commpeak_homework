require 'rspec'
require '../requester'
require '../ticket'
require 'time'

describe 'Ticket' do
  before(:all) do
    @requester = Requester.new("Voskov", "Voskov@email.com")
  end
  before(:each) do
    @subject = "test subject"
    @content = "test description"
    @created_at = Time.now.utc.iso8601
    @updated_at = Time.now.utc.iso8601
    @ticket = Ticket.new(@requester, @subject, @content, @created_at, @updated_at, :new)
  end

  it 'should create a ticket object' do
    subject = "First subject"
    content = "First description"
    expect {
      ticket = Ticket.new(@requester, subject, content, @created_at, @updated_at)
      expect(ticket.subject).to eq(subject)
      expect(ticket.content).to eq(content)
    }.to_not raise_error
  end

  it 'should create a ticket' do
    subject = "First subject"
    content = "First description"
    expect {
      ticket = Ticket.create_new_ticket(@requester)
      expect(ticket.subject).to eq(subject)
      expect(ticket.content).to eq(content)
    }.to_not raise_error
  end

  it 'shout convert to csv' do
    ticket = Ticket.new(@requester, @subject, @content, @created_at, @updated_at, :new, Ticket.get_next_id)
    ticket.add_to_csv
  end

  it 'should find by id' do
    ticket = Ticket.get_ticket_by_id(1)
    expect(ticket).to be_a(Ticket)
    expect(ticket.id).to eq("1")
  end

  it 'should delete ticket from csv' do
    ticket = Ticket.new(Requester.new("dsfkj dsf", "lskdjf@sdlkjrg.com"), "test", "content", "2017-03-18T14:38:27Z","2017-03-18T14:38:27Z", :new, 6)
    ticket.delete_from_csv
  end

  it 'should update ticket (no csv)' do
    ticket = Ticket.new(Requester.new("dsfkj dsf", "lskdjf@sdlkjrg.com"), "test", "content", "2017-03-18T14:38:27Z","2017-03-18T14:38:27Z", :new, 6)
    new_subject, new_content = "new subject", "new content"
    ticket.update_ticket(subject: new_subject)
    ticket.update_ticket(content: new_content)
    expect(ticket.subject).to eq(new_subject)
    expect(ticket.content).to eq(new_content)
  end

  it 'should update ticket (with csv)' do
    id = 3
    old_ticket = Ticket.get_ticket_by_id(id)
    new_subject, new_content = "new subject - ".concat((0...8).map { (65 + rand(26)).chr }.join), "new content - ".concat((0...8).map { (65 + rand(26)).chr }.join)

    old_ticket.update_ticket(subject: new_subject)
    old_ticket.update_ticket(content: new_content)
    new_ticket = Ticket.get_ticket_by_id(id)
    expect(new_ticket.subject).to eq(new_subject)
    expect(new_ticket.content).to eq(new_content)
  end

  it 'should count the amount of new tickets' do
    res = Ticket.count_tickets_by_param(:status, :new)
    puts res
  end

end