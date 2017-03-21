require_relative 'db_connector'
require 'user'

class UserDbConnector < DbConnector
  def get_user_by_email(email)
    stmt = "SELECT * FROM #{@@configs['DB']['users_table']} WHERE email = '#{email}'"
    res = exequte_query(stmt)
    if res.ntuples.zero?
      raise Exception.new("No such user")
    end
    return res.first
  end

  def create_new_user(user)
    stmt = "INSERT INTO #{@@configs['DB']['users_table']} values($1, $2, $3, $4)"
    params = [user.email, user.name, user.role, user.password]
    execute_prepared_statement(stmt, params)
  end
end