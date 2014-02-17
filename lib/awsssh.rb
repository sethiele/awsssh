#!/usr/bin/env ruby
require 'rubygems'
require 'net/ssh'
require 'json'

class Awsssh

  def do_start
    if ARGV[0] == "--list-accounts"
      list_accounts
    elsif ARGV[0] == "--list-servers" && !ARGV[1].nil?
      list_servers(ARGV[1])
    elsif !ARGV[0].nil? && ARGV[0][0,2] != "--"
      connect ARGV[0]
    else
      help
    end
  end

  CONFIG_DIR = "/Users/#{ENV['USER']}/.aws/"
  CONF_FILE = "aws_config_"
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
  # List stacks for a account
  #
  # * *Args*  :
  #   - +account+ -> Account name
  #
  # * *Returns* :
  #   - [Array] StackIDs

  def list_stacks(account)
    `awscfg #{account}`
    stacks = JSON.parse(`aws opsworks describe-stacks`)
    stack_ids = []
    stacks['Stacks'].each do |stack|
      stack_ids << stack['StackId']
    end
    return stack_ids
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
  # * *Returns* :
  #   - [String]
  #       This are the known AWS Accounts:
  #               - account

  def list_accounts
    length = 30
    puts "This are the known AWS Accounts:"
    config_files = Dir.entries(CONFIG_DIR)
    config_files.each do |file|
      if file[0,CONF_FILE.length] == CONF_FILE
        file_part = file.split("_")
        unless file_part[2].nil?
          printf "\t- %-#{length}s\n", file_part[2]
        end
      end
    end
  end

  ##
  # Server Name
  #
  # * *Args*  :
  #   - +stack+ -> Stack as JSON
  #
  # * *Returns* :
  #   - [String]
  #     - <servername> (<status>)

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
    stacks = list_stacks account
    stacks.each do |stack_id|
      stack = read_stack stack_id, account
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
    public_dns = nil
    stack_ids = list_stacks host[0]
    stack_ids.each do |stack_id|
      stack = read_stack(stack_id, host[0])
      stack["Instances"].each do |i|
        puts i["Hostname"]
        if i["Hostname"] == server
          public_dns = i["PublicDns"]
          break
        end
      end
      break unless public_dns.nil?
    end

    if public_dns.nil?
      puts "Server '#{server}' not found. Try ssh"
      exec "ssh #{server}"
      exit -1
    end

    puts "Connecting to #{server} (#{public_dns})"
    exec "ssh #{public_dns}"

  end



end