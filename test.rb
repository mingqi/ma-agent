#!/usr/bin/env ruby


File.open("/var/tmp/1.log", 'w') do | f | 
  (1..10000000000).each do | n |
    f.write("this is #{n}")
  end
end
