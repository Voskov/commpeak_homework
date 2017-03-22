$:.unshift(File.dirname(File.dirname(__FILE__)))
require 'rspec'
require 'src/requester'
require 'src/user'
require 'src/ticket'
require 'time'
Dir["../db_connector/*.rb"].each {|file| require file}

class RspecHelper
  def self.random_string
    return (0..3).map { (65 + rand(26)).chr }.join
  end
end