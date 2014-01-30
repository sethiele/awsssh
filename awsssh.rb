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

if host.match /^(?:[0-9]{1,3}\.){3}[0-9]{1,3}$/
  host_ip = host.split(".")
  host_name = "ec2-#{host_ip[0]}-#{host_ip[1]}-#{host_ip[2]}-#{host_ip[3]}.eu-west-1.compute.amazonaws.com"
  exec "ssh #{host_name}"
else
  exec "ssh #{host}"
end  
