require 'db_connector/db_connector'
require 'src/user'

class UserDbConnector < DbConnector
  def get_user_by_email(email)
    stmt = "SELECT * FROM #{@@configs['DB']['users_table']} WHERE email = '#{email}'"
    res = exequte_query(stmt)
    if res.ntuples.zero?
      raise Exception.new("No such user")
    end
    ret = res.first
    ret['role'] = ret['role'].to_sym
    return ret

  end

  def create_new_user(user)
    stmt = "INSERT INTO #{@@configs['DB']['users_table']} values($1, $2, $3, $4)"
    params = [user.email, user.name, user.role, user.password]
    execute_prepared_statement(stmt, params)
  end
end