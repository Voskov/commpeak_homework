require 'logger'
require 'digest'
require 'json'
require 'db_connector/user_db_connector'

class User
  attr_accessor :name, :email, :role, :password
  @@user_logger = Logger.new(STDOUT)
  @@udb = UserDbConnector.new
  ROLES = [:user, :manager]

  def initialize(name, email, role = :user, password = nil)
    @name = name
    @role = role.to_sym
    @password = password
    @email = email
    raise Exception("email address <#{email}> is invalid") unless valid_email? # TODO - something discriptive
    raise Exception("role must be one of #{ROLES}") unless ROLES.include? @role
  end

  def self.create_new_user(name: nil, email: nil, role: nil, password: nil) # The parameters are here mainly for testing and debugging
    @@user_logger.debug("registering a new user")
    unless name
      puts "name please?"
      name = $stdin.gets.chomp
    end
    unless email
      puts "and your email?"
      email = $stdin.gets.chomp.downcase
    end
    unless password
      puts "password? (not used yet)"
      password = Digest::SHA1.hexdigest($stdin.gets.chomp)
    end
    unless role
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
    end
    user = User.new(name, email, role, password)
    begin
      user.register_user_to_db
      return user
    end
  end

  def register_user_to_db
    begin
      @@udb.create_new_user(self)
    rescue Exception => e
      @@user_logger.error("Could not create this user")
      @@user_logger.error(e.message.chomp.gsub("\n", " - "))
    end
  end

  def self.login
    puts "email please?"
    email = $stdin.gets.chomp.downcase
    begin
      user_hash = @@udb.get_user_by_email(email)
    rescue Exception => e
      @@user_logger.error("Could not login")
      @@user_logger.error(e.message)
      return
    end
    if user_hash['role'] == :manager
      require 'manager'
      user = Manager.new(user_hash['name'], user_hash['email'], user_hash['password'])
    else
      user = User.new(user_hash['name'], user_hash['email'], user_hash['role'], user_hash['password'])
    end
    puts "logged in as #{user.name}"
    return user
  end

  def valid_email?
    @email =~ /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
  end

  def to_hash
    return {name: @name, email: @email}
  end

  private :valid_email?
end