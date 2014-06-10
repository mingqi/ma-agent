require 'socket'

module Fluent
  class MonitorAtAgentInput < MonitorAt::PeriodicInput
    Fluent::Plugin.register_input('monat_agent', self)

    def initialize
      super
    end

    def configure(conf)
      super
    end

    def run
      hostname = Socket.gethostname

      time = Fluent::Engine.now
      record = {
        'agent' => {
          'hostname' => hostname,
          'version' => 'v0.0.1'
        }
      }
      Fluent::Engine.emit('agent', time, record) 
    end
  end
end