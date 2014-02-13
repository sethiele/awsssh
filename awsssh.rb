#!/usr/bin/env ruby
require 'rubygems'
require 'net/ssh'
require 'yaml'
require 'json'


##
# Renders the Help
#
# * *Returns* :
# - [String]
#       usage: awsssh [<instance-name>|parameters]
#                <instance-name>                Name of the instance
#       parameters:
#                --help                         This help
#                --list-accounts                List all known AWS Accounts
#                --list-servers <account>       List all Server for an AWS Account

def help
  length = 30
  puts "usage: awsssh [<instance-name>|parameters]"
  printf "\t %-#{length}s Name of the instance\n", "<instance-name>"
  puts  "parameters:"
  printf "\t %-#{length}s This help\n", "--help"
  printf "\t %-#{length}s List all known AWS Accounts\n", "--list-accounts"
  printf "\t %-#{length}s List all Server for an AWS Account\n", "--list-servers <account>"
end

##
# Handle the config file
#
# * *Returns* :
#   - all AWS Accounts and Stack-ids
#

def read_config
  begin
    conf_path = ENV['AWS_SSH_CONFIG_PATH'] || File.dirname(__FILE__) + '/config.yml'
    config = YAML.load_file(conf_path)
  rescue Errno::ENOENT
    puts "Configurationsdatei 'config.yml' nicht gefunden"
    exit -1
  end
end

##
# Read Stack
#
# * *Args*  :
#   - +stackid+ -> Stack ID
#   - +account+ -> Account name
#
# * *Returns* :
#   - Stecks JSON
#

def read_stack(stackid, account)
  `awscfg #{account}`
  JSON.parse(`aws opsworks describe-instances --stack-id #{stackid}`)
end

##
# Lists all AWS Accounts
#
# * *Args* :
#   - [String]
#       This are the known AWS Accounts:
#               - account

def list_accounts
  length = 30
  config = read_config
  puts "This are the known AWS Accounts:"
  config.each do |c|
    printf "\t- %-#{length}s\n", c[0]
  end
end

##
# Server Name
#
# * *Args*  :
#   - +stack+ -> Stack as JSON
#

def server_name(stack)
  stack["Instances"].each do |instance|
    printf "\t- %-20s %s\n", instance["Hostname"], instance["Status"]
  end
end

##
# List all Servers for a given AWS Account
#
# * *Args*    :
#   - +account+ -> AWS Account name
#

def list_servers(account)
  puts "This is the list of all Server for AWS Account #{account}:"
  config = read_config
  config[account].each do |stack|
    stack = read_stack stack[1], account
    server_name stack
  end
end

##
# Establish the connection
#
# * *Args*  :
#   - +server+ -> Server name
#

def connect(server)
  host = server.split("-")
  config = read_config
  stack = read_stack(config[host[0]][host[1]], host[0])


  public_dns = nil
  stack["Instances"].each do |i|
    if i["Hostname"] == server
      public_dns = i["PublicDns"]
      break
    end
  end

  if public_dns.nil?
    puts "Server '#{server}' not found. Try ssh"
    exec "ssh #{server}"
    exit -1
  end

  puts "Connecting to #{server} (#{public_dns})"
  exec "ssh #{public_dns}"

end

if ARGV[0] == "--list-accounts"
  list_accounts
elsif ARGV[0] == "--list-servers" && !ARGV[1].nil?
  list_servers(ARGV[1])
elsif !ARGV[0].nil? && ARGV[0][0,2] != "--"
  connect ARGV[0]
else
  help
end

