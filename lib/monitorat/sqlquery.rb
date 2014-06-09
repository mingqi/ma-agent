require 'mysql'
module MonitorAt

  class MysqlQuery

    def initialize(host, port, user, name, database)
      @conn = Mysql.connect(host, user, name, database, port) 
    end

    def query(sql)
      result = @conn.query(sql)      
      if result.num_rows > 1
        raise Exception.new('query return more than 1 row')
      end

      if result.num_fields > 1
        raise Exception.new('query return more than 1 fields')
      end

      result.each do | row |
        return row[0].to_i
      end
    end

    def close()
      if @conn
        @conn.close()
      end
    end

  end

  class OracleQuery
  end

  class SqlServerQuery
  end

end
