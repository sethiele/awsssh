#!/usr/bin/env ruby
require 'rubygems'
require 'net/ssh'
require 'json'
require "aws-sdk"
# require "pry"
require "inifile"
require "thor"

class Awsssh < Thor
  CONFIG_DIR = ENV['AWSSSH_CONFIG_DIR'] || "/Users/#{ENV['USER']}/.aws/"
  CONF_FILE = ENV['AWSSSH_CONFIG_FILE'] || "aws_config_"

  desc "-s SERVER [-a ACCOUNT]", "connect to a server"
  option :server, :aliases => '-s', :desc => "(required) The server name to connect with"
  option :account, :aliases => '-a', :desc => "Specify a account for a connection. Needet if the account don't came from the server name"
  option :list_accounts, :aliases => '-k', :type => :boolean, :desc => "List all Accounts"
  option :list_servers, :aliases => '-i', :desc => "List all Servers for a given Account", :banner => "ACCOUNT"
  # option :check_status, :alias => '-c', :type => :string, :desc => "Give information when the server status has changed to target.", :banner => "STATUS"
  long_desc <<-LONGDESC
    # Connect to a Server:


    > $ awsssh -s SERVER
    \x5 This will connect you to a Server. This will work only if the first part of the server name is the same as the account name.

    > $ awsssh -s SERVER -a ACCOUNT
    \x5 With -a you can spezify a account to connect with. The server name don't play any role.

    # List all Account:

    > $ awsssh [--list-accounts|-k]
    \x5 This will list all Accounts

    # List all Servers for a Account

    > $ awsssh [--list-servers|-i] ACCOUNT
    \x5 List all Servers vor Account ACCOUNT

    # Get notification when Server is in Status

  LONGDESC
  def connect
    if options[:server]
      connecting(options[:server], options[:account])
    elsif options[:list_accounts]
      list_accounts
    elsif options[:list_servers]
      list_servers(options[:list_servers])
    elsif options[:server]
      connecting(options[:server], options[:account])
    else
      help "connect"
    end
  end

  def help(*args)
    super("connect")
  end

  private
    ##
    # List stacks for a account
    #
    # * *Args*  :
    #   - +account+ -> Account name
    #
    # * *Returns* :
    #   - [Array] StackIDs
    def list_stacks(account)
      ow = awscfg(account)
      stacks = ow.client.describe_stacks[:stacks]
      stack_ids = []
      stacks.each do |stack|
        stack_ids << stack[:stack_id]
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
      ow = awscfg(account)
      ow.client.describe_instances({:stack_id => stackid})
      # JSON.parse(`aws opsworks describe-instances --stack-id #{stackid}`)
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
          unless file_part.last.nil?
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
      stack[:instances].each do |instance|
        printf "\t- %-20s %s\n", instance[:hostname], instance[:status]
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
    def connecting(server, account=nil)
      public_dns = nil
      host = server.split("-")
      ac = account || host[0]
      stack_ids = list_stacks ac
      stack_ids.each do |stack_id|
        stack = read_stack(stack_id, ac)
        stack.instances.each do |i|
          if i[:hostname] == server
            public_dns = i[:public_dns]
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

    def awscfg(account)
      if cnf = IniFile.load(CONFIG_DIR + CONF_FILE + account)
        cnf = cnf['default']
        return AWS::OpsWorks.new(
          access_key_id: cnf['aws_access_key_id'],
          secret_access_key: cnf['aws_secret_access_key'],
          region: cnf['region']
        )
      else
        puts "No config #{CONF_FILE}#{account} found. Maybe use -a to specify a account."
        exit -1
      end
    end
  default_task :connect
end
