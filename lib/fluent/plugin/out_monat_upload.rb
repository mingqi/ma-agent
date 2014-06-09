module Fluent
  class MonitorAtUploadOutput < Fluent::BufferedOutput
    Fluent::Plugin.register_output('monat_upload', self)

    config_param :remote_host, :string, :default => 'localhost'
    config_param :remote_port, :integer, :default => 9998
    config_param :key, :string, :default => 'tsds'
    config_param :uri, :string, :default => '/tsd'

    def initialize
      super
      encoding = Encoding.default_internal
      Encoding.default_internal = nil
      require 'rest_client'
      Encoding.default_internal = encoding
    end

    def configure(conf)
      super
      if !@key 
        raise Fluent::ConfigError, "key is necessary on monat_upload"
      end
    end

    def format(tag, time, record)
      result = ''
      timestamp = Time.at(time).strftime('%Y-%m-%dT%H:%M:%S%:z')
      tsds = record[@key]
      tsds = [tsds] if (not tsds.is_a? Array)
      tsds.reduce('') do | result, tsd |
        tsd['timestamp'] ||= timestamp 
        result << Yajl.dump(tsd) << "\n"
      end
    end

    def write(chunk)
      $log.info "write chunk..."
      i = 0
      payload = ''
      StringIO.new(chunk.read).each do |line|
        i = i + 1
        is_new_payload = (i == 1)
        payload << '[' if is_new_payload
        payload << ',' if !is_new_payload
        payload << line.chomp

        if(payload.bytesize >= 0)
          payload << ']'
          _upload(payload)
          i = 0
          payload = ''
        end
      end 

      if(payload.bytesize > 0)
        payload << ']'
        _upload(payload)
      end

    end 

    private

    def _upload(payload)
      $log.info "upload TSD data: #{payload}"
      begin
        res = RestClient.post("http://#{@remote_host}:#{@remote_port}#{@uri}", _gzip(payload), 'Content-Type' => 'application/json', 'Content-Encoding' => 'gzip' )
      rescue  RestClient::BadRequest
        $log.warn "Bad data was send to monitorat service, discard them!!"
      end         
    end

    def _gzip(string)
      wio = StringIO.new("w")
      w_gz = Zlib::GzipWriter.new(wio)
      w_gz.write(string)
      w_gz.close
      compressed = wio.string
    end
  end
end