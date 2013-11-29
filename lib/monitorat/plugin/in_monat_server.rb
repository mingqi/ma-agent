require 'monitorat/fluentd'
require 'monitorat/sysstat'
require 'socket'

module MonitorAt  

  class SystemStatInput < MonitorAt::PeriodicInput
    Fluent::Plugin.register_input('monat_server', self)

    config_param :tag, :string

    include MonitorAt::Delta

    def initialize
      super
    end

    def configure(conf)
      super
      if !@tag
        raise Fluent::ConfigError, "tag is necessary on monat_server"
      end
    end

    def run
      time = Fluent::Engine.now
      hostname = Socket.gethostname
      cpu_delta_time = delta_values(Sysstat.cpu_time)
      if not cpu_delta_time['total']
        return
      end
      cpu_delta_time.each {|k,v| cpu_delta_time[k] = v.to_f}
      metric_values = {}
      metric_values["server/#{hostname}/cpu/user_usage"] = cpu_delta_time['user'] / cpu_delta_time['total'] if cpu_delta_time['user']
      metric_values["server/#{hostname}/cpu/system_usage"] = cpu_delta_time['system'] / cpu_delta_time['total'] if cpu_delta_time['system']
      metric_values["server/#{hostname}/cpu/iowait_usage"] = cpu_delta_time['iowait'] / cpu_delta_time['total'] if cpu_delta_time['iowait']

      tsds = metric_values.map do |m_name, m_value|
        { 'metric-name' => m_name,
          'value' => (100 * m_value).round(2)
        }
      end

      Fluent::Engine.emit(@tag, time, {'tsds' => tsds}) if not tsds.empty?
    end

  end

end