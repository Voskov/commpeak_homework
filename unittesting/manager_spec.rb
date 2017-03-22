require_relative 'rspec_helper'
require 'src/manager'

describe 'tests manager' do
  def rnd_str
    return (0..3).map { (65 + rand(26)).chr }.join
  end
  before(:all) do
    rnd = rnd_str
    @man = Manager.new("manager test-#{rnd}", "manager-#{rnd}@email.com", rnd)
  end
  it 'should Init a manager' do
    expect{
      @man = Manager.new("manager test", "manager@email.com", rnd_str)
    expect(@man).to be_a(Manager)
    }.to_not raise_error
  end

  it 'should save a manager in the DB' do
    skip "done"
    @man.register_user_to_db
  end

  it 'should display all tickets' do
    @man.display_all_tickets
  end
end