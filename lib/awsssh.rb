require "awsssh/version"
require "thor"
require "inifile"
require "aws-sdk"
require "colorize"


module Awsssh
  class Awsssh < Thor

    def initialize(*args)
      super
      @text_colors = {
        :infotext => :cyan,
        :infotext_sub => :yellow,
        :status => {
          :online => :green,
          :stopped => :light_red
          }
        }
    end

    desc "list_profiles", "List all your avavible profiles"
    def list_profiles()
      credentials = open_credantial_file
      puts "List of all known AWS Accounts"
      puts
      credentials.sections.each do |section|
        puts "   #{section}"
      end
    end

    desc "list_server PROFILE", "List all Server for given profile"
    method_option :all, :type => :boolean, :aliases => "-a", :default => false, :desc => "Show all Server"
    def list_server(profile)
      credentials = open_credantial_file
      raise "Profile `#{profile}` not found. Please try `awsssh list_profiles`" if credentials[profile].empty?
      aws_connection(profile, credentials)

      puts "Stacks and instances for profile `#{profile}`".colorize(@text_colors[:infotext])
      puts "only online server".colorize(@text_colors[:infotext_sub]) unless options[:all]
      puts

      @client.describe_stacks.stacks.each do |stack|
        puts "##### Stack: #{stack.name}"
        @client.describe_instances({stack_id: stack.stack_id}).instances.each do |instance|
          printf "             %-20s status: %-11s %s\n".colorize(@text_colors[:status][instance.status.to_sym]) % [instance.hostname, instance.status, public_dns(instance)] if instance.status == "online" or options[:all]
        end
        puts ""
      end
    end

    desc "connect SERVERNAME", "Connect to Hostname"
    method_option :profile, :desc => "specify a profile - see `awsssh list_profiles`"
    def connect (hostname)
      hostname_parts = hostname.split("-")
      profile = options[:profile] || hostname_parts[0]
      credentials = open_credantial_file
      puts "Profile `#{profile}` not found. Try `awsssh SERVERNAME --profile PROFILE`" if credentials[profile].empty?
      exit -1 if credentials[profile].empty?

      aws_connection(profile, credentials)
      puts "looking for hostname `#{hostname}` in profile `#{profile}`. This may take a while..."
      puts
      public_dns = find_server(@client.describe_stacks.stacks, hostname)
      if public_dns.nil?
        puts "`#{hostname}` was not found or has no public ip."
        puts "Try `awsssh list_server PROFILE`"
        puts "checking your local ssh config..."
        puts
        exec "ssh #{hostname}"
        exit -1
      else
        puts "start ssh connection to `#{hostname}`..."
        puts
        exec "ssh #{public_dns}"
        exit 0
      end
    end

    desc "version", "Version"
    def version
      puts "version #{VERSION}"
    end


    # @private
    def help(command = nil, subcommand = false)
     super
     puts "For more information visit https://github.com/sethiele/awsssh"
     puts ""
    end



    private

    ##
    # open and check credential file
    #
    def open_credantial_file()
      if ENV['AWS_CREDENTIAL_FILE'].to_s.empty?
        $stderr.puts "$AWS_CREDENTIAL_FILE not set"
        Process.exit!(4)
      end
      unless File.exist?(ENV['AWS_CREDENTIAL_FILE'])
        $stderr.puts "Credential File not found. Please check path `#{ENV['AWS_CREDENTIAL_FILE']}`"
        Process.exit!(4)
      end
      IniFile.load(ENV['AWS_CREDENTIAL_FILE'])
    end

    ##
    #
    def aws_connection(profile, credentials = nil)
      credentials ||= open_credantial_file
      @client = Aws::OpsWorks::Client.new({
        region: credentials[profile]["region"],
        credentials: Aws::Credentials.new(
          credentials[profile]["aws_access_key_id"],
          credentials[profile]["aws_secret_access_key"]
        )
      })
    end

    def public_dns(instance)
      public_ip = instance.public_ip || instance.elastic_ip
      return nil if public_ip == nil
      "ec2-#{public_ip.gsub(".", "-")}.#{instance.availability_zone.chop}.compute.amazonaws.com"
    end

    def find_server(stacks, hostname)
      stacks.each do |stack|
        @client.describe_instances({stack_id: stack.stack_id}).instances.each do |instance|
          return public_dns(instance) if instance.hostname == hostname
        end
      end
      return nil
    end
  end
end
