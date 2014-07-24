#!/usr/bin/env ruby

STDIN.read.split("\n").each do |a|
  puts "###{a}"
  command = "echo '#{a}' | /var/tmp/find-requires"
  # command = "ls -l '#{a}'"
  puts `#{command} `
end
