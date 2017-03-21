require 'logger'
require 'digest'
require 'json'
require 'db_connector/user_db_connector'

class User
  attr_accessor :name, :email, :role, :password
  @@user_logger = Logger.new(STDOUT)
  @@udb = UserDbConnector.new

  def initialize(name, email, role = :user, password = nil)
    @name = name
    @email = email if valid_email?(email)
    @role = role
    @password = password
    if valid_email?(email)
      @email = email
    else
      raise Exception("email address <#{email}> is invalid") # TODO - something discriptive
    end
  end

  def self.create_new_user
    @@user_logger.debug("registering a new user")
    puts "name please?"
    name = $stdin.gets.chomp
    puts "and your email?"
    email = $stdin.gets.chomp
    puts "password? (not used yet)"
    password = Digest::SHA1.hexdigest($stdin.gets.chomp)
    puts 'Is this an management user? (Y/N)'
    manage_response = $stdin.gets.chomp
    counter = 0
    until %w(y n Y N yes no Yes No YES NO).include? manage_response
      counter += 1
      puts "Come on, yes or no?"

      if counter > 3
        puts "I'm gonna take it as a 'no'"
        manage_response = 'n'
      end
    end
    role = nil
    case manage_response
      when "y", "Y", "yes", "Yes", "YES"
        role = :manager
      when "n", "N", "no", "No", "NO"
        role = :user
    end
    user = User.new(name, email, role, password)
    begin
      user.register_user_to_db
    rescue Exception => e
      @@user_logger.error("Could not create this user")
      @@user_logger.error(e.message.chomp.gsub("\n", " - "))
    end
    return user
  end

  def register_user_to_db
    @@udb.create_new_user(self)
  end

  def self.login
    puts "email please?"
    email = $stdin.gets.chomp
    user_hash = @@udb.get_user_by_email(email)

    user = User.new(user_hash['name'], user_hash['email'], user_hash['role'], user_hash['password'])
    puts "logger in as #{user.name}"
    return user
  end

  def valid_email?(email)
    (email =~ /^(([A-Za-z0-9]*\.+*_+)|([A-Za-z0-9]+\-+)|([A-Za-z0-9]+\+)|([A-Za-z0-9]+\+))*[A-Z‌​a-z0-9]+@{1}((\w+\-+)|(\w+\.))*\w{1,63}\.[a-zA-Z]{2,4}$/i)
  end

  def to_hash
    return {name: @name, email: @email}
  end

  def to_s
    to_hash.to_s
  end

  def to_json
    to_hash.to_json
  end

  private :valid_email?
end