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
      metrics = {}

      uptime = delta_values({'uptime' => Sysstat.uptime})
      elapsed = uptime['uptime'] || 0

      cpu_time = {}
      Sysstat.cpu_time.each do |k, v| 
        cpu_time["server/#{hostname}/cpu/#{k}"] = v
      end 
      cpu_time = delta_values(cpu_time)
      if total = cpu_time["server/#{hostname}/cpu/total"]
        cpu_time.select{|k,_| not k.end_with?('/total')}.each do |k,v|
          metrics[k] = (100 * v / total).round(2)
        end 
      end

      Sysstat.meminfo.each do |k, v|
        metrics["server/#{hostname}/memory/#{k}"] = v
      end

      Sysstat.swap.each do |k, v|
        metrics["server/#{hostname}/swap/#{k}"] = v
      end

      Sysstat.ifs.each do |if_name|
        if_stat = {}
        Sysstat.if_stat(if_name).each { |k,v| if_stat["server/#{hostname}/if/#{if_name}/#{k}"] = v }
        delta_values(if_stat).each do |k, v|
          metrics[k] = v
          if elapsed > 0
            metrics["#{k}_rate"] = ((v * 1000) / elapsed).round(2)
          end
        end 
      end

      Sysstat.disks.each do |disk_name, mount_point|
        disk_stat = {}
        Sysstat.disk_stat(disk_name).each {|k,v| disk_stat["server/#{hostname}/disk/#{disk_name}/#{k}"] = v}
        delta_values(disk_stat).each do |k, v|
          metrics[k] = v
          if elapsed > 0
            if ['read_times', 'read_merged_times', 'read_bytes', 
                'write_times', 'write_merged_times', 'write_bytes'].any? {|e| k.end_with?(e) }
              metrics["#{k}_rate"] = ((v * 1000) / elapsed).round(2)
            end

            if k.end_with? 'time_on_io'
              metrics["server/#{hostname}/disk/#{disk_name}/util"] = (100 * v / elapsed).round
            end
          end
        end

        Sysstat.disk_space(mount_point).each do | k, v |
          metrics["server/#{hostname}/disk_space/#{disk_name}/#{k}"] = v
        end
      end

      tsds = metrics.inject([]) do |r, (k,v)|
        r << {'metric-name' => k, 'value' => v}
      end

      Fluent::Engine.emit(@tag, time, {'tsds' => tsds}) if not tsds.empty?
    end

  end

end