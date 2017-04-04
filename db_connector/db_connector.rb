require 'yaml'
require 'pg'
require 'singleton'

class DbConnector
  attr_reader :configs
  @@configs = YAML.load_file(File.join(File.dirname(__FILE__), "..", "config", "config.yaml"))
  include Singleton

  def initialize
    @database, @user, @password = @@configs['DB']['db_name'], @@configs['DB']['username'], @@configs['DB']['password']
  end

  def create_db
    begin
      con = PG.connect(dbname: "postgres", user: @user, password: @password)
      con.exec ("CREATE DATABASE #{@database}")
    rescue PG::Error => e
      puts e.message
    ensure
      con.close if con
    end
  end

  def create_tickets_table
    stmt = "CREATE TABLE #{@@configs['DB']['tickets_table']}(id INT PRIMARY KEY, requester VARCHAR(63), status VARCHAR(15), subject VARCHAR(255), content TEXT, created_at timestamp, updated_at timestamp, comment VARCHAR(255))"
    execute_statement(stmt)
  end

  def create_users_table
    stmt = "CREATE TABLE #{@@configs['DB']['users_table']}(email VARCHAR(63) PRIMARY KEY, name VARCHAR(63), role VARCHAR(15), password VARCHAR(63))"
    execute_statement(stmt)
  end

  def create_tables
    create_tickets_table
    create_users_table
  end

  def drop_table(table) # 'cause you never know
    stmt = "DROP TABLE #{table}"
    execute_statement(stmt)
  end

  def drop_database(database)
    stmt = "DROP DATABASE #{database}"
    execute_statement(stmt)
  end

  def execute_statement(statement)
    con = PG.connect(dbname: @database, user: @user, password: @password)
    con.exec(statement)
  end

  def execute_prepared_statement(prepared, params_arr)
    con = PG.connect(dbname: @database, user: @user, password: @password)
    con.prepare('stm', prepared)
    con.exec_prepared('stm', params_arr)
  end

  def exequte_query(statement)
    con = PG.connect(dbname: @database, user: @user, password: @password)
    res = con.exec(statement)
    return res
  end

  def exequte_prepared_query(prepared, params_arr)
    con = PG.connect(dbname: @database, user: @user, password: @password)
    con.prepare('stm', prepared)
    res = ccon.exec_prepared('stm', params_arr)
    return res
  end
end