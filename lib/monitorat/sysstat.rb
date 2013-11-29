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

end