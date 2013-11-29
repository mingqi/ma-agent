require 'monitorat/fluentd'
require 'monitorat/sysstat'
require 'socket'

module MonitorAt
  class MetaInput < MonitorAt::PeriodicInput
    Fluent::Plugin.register_input('monat_meta', self)
    config_param :tag, :string

    def initialize
      super
    end

    def configure(conf)
      super
      if !@tag
        raise Fluent::ConfigError, "tag is necessary on monat_meta"
      end
    end

    def run
      hostname = Socket.gethostname
      disks = Sysstat.disks 
      disks_meta = []
      disks.each do |device, mount|
        disks_meta << {:device => device, :mount => mount}
      end

      time = Fluent::Engine.now
      record = {
        'ma-meta' => {
          'category' => 'server',
          'instance' => hostname,
          'metadata' => {
            'disks' => disks_meta
          }
        }
      }
      Fluent::Engine.emit(@tag, time, record) 
    end
  end
end