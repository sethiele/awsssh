#!/usr/bin/env ruby
require 'rubygems'
require 'net/ssh'
require 'yaml'
require 'json'


if ARGV[0].nil?
  puts "Host nicht angegeben."
  exit -1
end

host = ARGV[0].split("-")

begin
  conf_path = ENV['AWS_SSH_CONFIG_PATH'] || File.dirname(__FILE__) + '/config.yml'
  puts conf_path 
  config = YAML.load_file(conf_path)
rescue Errno::ENOENT
  puts "Configurationsdatei 'config.yml' nicht gefunden"
  exit -1
end

puts "changing awscfg to #{host[0]}"
`awscfg #{host[0]}`

puts "waiting for stacks settigs"
stack_settings = JSON.parse(`aws opsworks describe-instances --stack-id #{config[host[0]][host[1]]}`)
#puts stack_settings

public_dns = nil
stack_settings["Instances"].each do |i|
  #puts i
  if i["Hostname"] == ARGV[0]
    public_dns = i["PublicDns"]
    break
  end
end

if public_dns.nil?
  puts "Host '#{ARGV[0]}' nicht gefunden."
  exit -1
end

puts "Verbinde mit #{ARGV[0]} (#{public_dns})"
exec "ssh #{public_dns}"
