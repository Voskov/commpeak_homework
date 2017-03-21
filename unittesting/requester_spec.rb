require_relative 'rspec_helper'

describe 'Requester' do
  before(:all) do
    rnd = RspecHelper.random_string
    @name = "Voskov #{rnd}"
    @email = "voskov.#{rnd}@email.com"
  end
  it 'creates a requester' do
    expect { r = Requester.new(@name, @email) }.to_not raise_error
    r = Requester.new(@name, @email)
    expect(r.name).to eq(@name)
    expect(r.email).to eq(@email)
  end

  it 'creates and saves requester' do
    role = rand > 0.5 ? :manager : :user
    r = Requester.new(@name, @email, role)
    r.register_user_to_db
  end
  it 'tests errors' do
    false_email = "false_email"
    expect { r = Requester.new(@name, false_email) }.to raise_error
  end
  describe "convertion" do
    before(:all) do
      @r = Requester.new(@name, @email)
    end
    it 'saves the user to the db' do
      @r.register_user_to_db
    end
  end
end

