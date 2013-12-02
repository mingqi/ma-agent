require 'pathname'

class Sysstat

  def self.uptime
    File.open("/proc/uptime", "r") do |f|
      sp  = f.readline.split
      return sp[0].to_f * 1000
    end
  end
  
  def self.cpu_time
    result = { 'total' => 0}
    name_col_map = {
      'user' => 1,
      'nice' => 2,
      'system' => 3,
      'idle' => 4,
      'iowait' => 5,
      'hardirq' => 6,
      'softirq' => 7
    }
    File.open('/proc/stat', 'r').each  do | line |
      if line.start_with?('cpu ')
        sp = line.split
        name_col_map.each { |name, col|
          result[name] = sp[col].to_i
          result['total'] = result['total'] + result[name]
        } 
        break
      end
    end
    return result
  end

  def self.disks(only_mounted=true)
    result = []
    devs = {}
    File.open('/proc/diskstats', 'r').each do | line |
      sp = line.split
      next if not sp[2] =~ /^(dm-\d+|md\d+|[hsv]d[a-z]+(\d+)?|cciss\/c\dd\d)$/
      devs[sp[2]] = nil
    end 

    File.open("/proc/mounts", "r").each do | line |  
      dev_name, mount_point = line.split[0..1]
      if dev_name.start_with? "/dev/"
        dev_path = Pathname.new(dev_name)
        if dev_path.exist? and dev_path.symlink?
          dev_name = dev_path.realpath.to_path
        end

        dev_name = dev_name[5..-1]
      end
      devs[dev_name] = mount_point if devs.include? dev_name
    end 

    only_mounted ? devs.select {| k, v| v && v !='/boot' } : devs
  end

  def self.disk_stat(dev_name)
    result = nil
    File.open('/proc/diskstats', 'r').each do | line |
      sp = line.split
      col_map = {
        'read_times' => 3,
        'read_merged_times' => 4,
        'read_sectors' => 5,
        'write_times' => 7,
        'write_merged_times' => 8,
        'write_sectors' => 9,
      } 

      if sp[2] == dev_name
        result = {}
        col_map.each do |k, v|  
          result[k] = sp[v].to_i
        end
        result['read_bytes'] = result['read_sectors'] * 512
        result['write_bytes'] = result['write_sectors'] * 512
      end
    end
    result
  end

  def self.ifs
    result = []
    File.open('/proc/net/dev', 'r').each do | line |
      sp = line.split(':')
      next if sp.count < 2
      result << sp[0].strip if not sp[0].strip =~ /^(lo|bond\d+|face|.+\.\d+)$/
    end
    return result
  end

  def self.if_stat(if_name)
    col_map = {
      'read_bytes' => 0,
      'read_packets' => 1,
      'read_errs' => 2,
      'read_drop' => 3,
      'read_fifo' => 4,
      'read_frame' => 5,
      'read_compressed'  => 6,
      'read_multicast' => 7,
      'write_bytes' => 8,
      'write_packets' => 9,
      'write_errs' => 10,
      'write_drop' => 11,
      'write_fifo' => 12,
      'write_frame' => 13,
      'write_compressed'  => 14,
      'write_multicast' => 15,
    }

    result = {}
    File.open('/proc/net/dev', "r").each do | line |
      sp = line.split(':')
      next if sp.count < 2
      if sp[0].strip == if_name
        sp2 = sp[1].split
        col_map.each {|field, column| result[field] = sp2[column].to_i }
        break
      end
    end

    return result
  end
end