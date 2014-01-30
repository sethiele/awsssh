#!/usr/bin/env ruby
require 'rubygems'
require 'net/ssh'

if ARGV[0].nil?
  puts "Host nicht angegeben."
  exit -1
end

host = Net::SSH::Config.for(ARGV[0])[:host_name]
if host.nil?

  puts "Host nicht bekannt."
  exit -1
end

exec "ssh #{host}"
