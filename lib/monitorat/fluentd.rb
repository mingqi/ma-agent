module MonitorAt

  class PeriodicInput < Fluent::Input
    config_param :interval, :integer, :default => 1

    def start
      @stop_flag = false      
      @thread = Thread.new do 
        until @stop_flag 
          begin
            run()   
          rescue Exception => e
            puts e.message  
            puts e.backtrace
          ensure
            sleep(@interval)
          end
        end
      end
    end

    ### child class need to implement
    # def run
    # end

    def shutdown
      puts "shutdowning..."
      @stop_flag =  true
      if @thread
          @thread.run
          @thread.join
          @thread = nil
      end
    end
  end

  module Delta
    def delta_values(values)
      @last_values ||= {}
      result = {}
      values.each do |key, value|
        if@last_values.has_key? key
          result[key] =  value - @last_values[key] 
        end
        @last_values[key] = value
      end  

      result
    end
  end
end