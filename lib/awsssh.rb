require "awsssh/version"
require 'net/ssh'
require 'json'
require "aws-sdk"
Bundler.require(:default, :development)
require "inifile"
require "thor"

module Awsssh
  class Awsssh < Thor
    CONFIG_DIR = ENV['AWSSSH_CONFIG_DIR'] || "/Users/#{ENV['USER']}/.aws/"
    CONF_FILE = ENV['AWSSSH_CONFIG_FILE'] || "aws_config_"

    desc "-s SERVER [-a ACCOUNT]", "connect to a server"
    option :server, :aliases => '-s', :desc => "(required) The server name to connect with"
    option :account, :aliases => '-a', :desc => "Specify a account for a connection. Needet if the account don't came from the server name"
    option :list, :aliases => '-l', :desc => "List any items use with -s for Servers or -a ACCOUNT for accounts", :type => :boolean
    option :check, :aliases => '-c', :desc => "Alerts when -c STATE comes up for -s SERVER"
    long_desc <<-LONGDESC
      # Connect to a Server:


      > $ awsssh -s SERVER
      \x5 This will connect you to a Server. This will work only if the first part of the server name is the same as the account name.

      > $ awsssh -s SERVER -a ACCOUNT
      \x5 With -a you can spezify a account to connect with. The server name don't play any role.

      # List all Account:

      > $ awsssh -l -a
      \x5 This will list all Accounts

      # List all Servers for a Account

      > $ awsssh -l -a ACCOUNT
      \x5 List all Servers vor Account ACCOUNT

      # Check Server Status

    LONGDESC
    def connect
      if options[:list] && options[:account]
        list_accounts
      elsif options[:list] && options[:server]
        list_servers(options[:server])
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
          host = build_hostname(instance)
          printf "\t- %-20s %s \t %-15s \t %s\n", instance[:hostname], instance[:status], host[:ip], host[:hostname]
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
              public_dns = build_hostname(i)[:hostname]
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

      def build_hostname(instance)
        host = {}
        if instance[:status] != 'online'
          host[:ip] = host[:hostname] = nil
          return host
        end
        az = (instance[:availability_zone][-1].match(/[a-z]/)) ?
          instance[:availability_zone][0..-2] :
          instance[:availability_zone]
        host[:ip] = instance[:public_ip] || instance[:elastic_ip]
        host[:hostname] = "ec2-#{host[:ip].gsub("\.", "\-")}.#{az}.compute.amazonaws.com"
        host
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
end
