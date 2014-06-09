require 'monitorat/sqlquery'
require 'monitorat/fluentd'

module Fluent
  class MonitorAtSqlInput < MonitorAt::PeriodicInput
    Fluent::Plugin.register_input('monat_sql', self)

    config_param :metric, :string
    config_param :host, :string
    config_param :port, :integer
    config_param :username, :string
    config_param :password, :string
    config_param :database, :string
    config_param :sql, :string

    def initialize
      super
    end

    def configure(conf)
      super
    end

    def run
      query = MonitorAt::MysqlQuery.new(@host, @port, @username, @password, @database)      
      value = query.query(@sql)
      if value
        Fluent::Engine.emit('metric', time = Fluent::Engine.now, {'tsd' =>
          { 'metric' => @metric,
            'value' => value
          } 
         })
      end  
    end

  end 
end