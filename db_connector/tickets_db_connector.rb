require_relative 'db_connector'

class TicketsDbConnector < DbConnector
  @@tickets_table = @@configs['DB']['tickets_table']

  # def create_tickets_table
  #   stmt = "CREATE TABLE #{@@tickets_table}(id INT PRIMARY KEY, requester JSON, status VARCHAR(15), subject VARCHAR(255), content TEXT, created_at timestamp, updated_at timestamp, comment VARCHAR(255))"
  #   execute_statement(stmt)
  # end

  # TODO - Rewrite this statement
  def save_ticket(ticket)
    stmt = "INSERT INTO #{@@tickets_table} values(#{ticket.id}, '#{ticket.requester.to_json}', '#{ticket.status}', '#{ticket.subject}', '#{ticket.content}', '#{ticket.created_at}', '#{ticket.updated_at}', '#{ticket.comment}')"
    execute_statement(stmt)
  end

  def save_ticket_prepared(ticket)
    stmt = "INSERT INTO #{@@tickets_table} values($1, $2, $3, $4, $5, $6, $7, $8)"
    params = [ticket.id, ticket.requester.to_json, ticket.status, ticket.subject, ticket.content, ticket.created_at, ticket.updated_at, ticket.comment]
    execute_prepared_statement(stmt, params)
  end

  def count_by_param(param)
    stmt = "SELECT #{param}, count(*) FROM  #{@@tickets_table} GROUP BY #{param}"
    res = exequte_query(stmt)
    return res
  end

  def return_all_tickets
    stmt = "SELECT t.id, u.name, t.status, t.subject, t.content
            FROM #{@@configs['DB']['users_table']} u ,#{@@tickets_table} t
            WHERE u.email=t.requester
            ORDER BY t.id;"
    res = exequte_query(stmt)
  end


end