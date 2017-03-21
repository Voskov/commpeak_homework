$:.unshift(File.dirname(File.dirname(__FILE__)))
require 'rspec'
require '../requester'

describe 'Requester' do
  before(:all) do
    @name = "Voskov"
    @email = "voskov@email.com"
  end
  it 'creates a requester' do
    expect { r = Requester.new(@name, @email) }.to_not raise_error
    r = Requester.new(@name, @email)
    expect(r.name).to eq(@name)
    expect(r.email).to eq(@email)
  end

  it 'tests errors' do
    false_email = "false_email"
    expect { r = Requester.new(@name, false_email) }.to raise_error
  end
  describe "convertion" do
    before(:all) do
      @r = Requester.new(@name, @email)
    end
    it "to_s" do
      expected = "{:name=>\"Voskov\", :email=>\"voskov@email.com\"}"
      expect(@r.to_s).to eq(expected)
    end
    it "to_hash" do
      expected = {:name => "Voskov", :email => "voskov@email.com"}
      expect(@r.to_hash).to eq(expected)
    end
    it "to_json" do
      expected = "{\"name\":\"Voskov\",\"email\":\"voskov@email.com\"}"
      expect(@r.to_json).to eq(expected)
    end

    it 'saves the user to the db' do
      @r.register_user_to_db
    end
  end
end

