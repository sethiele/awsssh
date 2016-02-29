require "awsssh/version"
require "thor"
require "inifile"
require "aws-sdk"
require "colorize"
require "open-uri"
require "json"


module Awsssh
  ##
  # Main awsssh class
  # @since 1.0.0
  class Awsssh < Thor

    ##
    # overwrite initializer
    # @since 3.0.0
    # @private
    #
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
      check_version
    end

    ##
    # List all profiles
    # @since 3.0.0
    # @example
    #   awsssh list_profiles
    #
    desc "list_profiles", "List all your avavible profiles"
    def list_profiles()
      credentials = open_credantial_file
      puts "List of all known AWS Accounts"
      puts
      credentials.sections.each do |section|
        puts "   #{section}"
      end
    end

    ##
    # List all server for a profile
    #
    # @!method list_server(profile)
    # @since 3.0.0
    # @param profile [String] Profile name
    # @example
    #   awsssh list_server PROFILE
    #
    desc "list_server PROFILE", "List all Server for given profile"
    method_option :all, :type => :boolean, :aliases => "-a", :default => false, :desc => "Show all Server"
    def list_server(profile)
      credentials = open_credantial_file

      puts "Profile `#{profile}` not found. Try `awsssh list_profiles`" if credentials[profile].empty?
      exit -1 if credentials[profile].empty?

      aws_connection(profile, credentials)

      puts "Stacks and instances for profile `#{profile}`".colorize(@text_colors[:infotext])
      puts "only online server".colorize(@text_colors[:infotext_sub]) unless options[:all]
      puts

      server_number = 0
      server_online = []

      @client.describe_stacks.stacks.each do |stack|
        puts "##### Stack: #{stack.name}"
        @client.describe_instances({stack_id: stack.stack_id}).instances.each do |instance|
          if instance.status == "online"
            server_number+=1
            server_online[server_number] = public_dns = public_dns(instance)
            printf("[%02d]" % [server_number])
          else
            print "    "
            public_dns = "-"
          end
          printf "         %-20s status: %-11s %s\n".colorize(@text_colors[:status][instance.status.to_sym]) % [instance.hostname, instance.status, public_dns] if instance.status == "online" or options[:all]
        end
        puts ""
      end
      select_server(server_online)
    end

    ##
    # Connect to SERVERNAME
    #
    # @!method connect (hostname)
    # @since 3.0.0
    # @param hostname [String] Hostname
    # @param profile [String] Profile name (optional)
    # @example Without profile
    #   awsssh connect SERVERNAME
    # @example With profile
    #   awsssh connect SERVERNAME --profile PROFILE
    #
    desc "connect SERVERNAME", "Connect to Hostname"
    method_option :profile, :desc => "specify a profile - see `awsssh list_profiles`"
    def connect (hostname)
      hostname_parts = hostname.split("-")
      profile = options[:profile] || hostname_parts[0]
      credentials = open_credantial_file
      puts "Profile `#{profile}` not found. Try `awsssh connect SERVERNAME --profile PROFILE`" if credentials[profile].empty?
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
        connect_server hostname
      else
        puts "start ssh connection to `#{hostname}`..."
        puts
        connect_server public_dns
      end
    end

    ##
    # Version
    # @since 3.0.0
    # @example
    #   awsssh version
    desc "version", "Version"
    def version
      puts "version #{VERSION}"
    end


    ##
    # Help overwrite
    # @private
    # @since 3.0.0
    #
    def help(command = nil, subcommand = false)
     super
     puts "For more information visit https://github.com/sethiele/awsssh"
     puts ""
    end



    private

    ##
    # Select to connect to a server directly
    # @since 3.2.0
    # @param server_list [Sting<Array>] List of all server
    #
    def select_server(server_list)
      while true
        puts "Would you like to connect to any server directly?"
        if check_in_tmux
          puts "Please select server"
          puts "Select multible server by enter server number comma seperated."
          print "Server numer(s) (Enter to exit): "
        else
          puts "Please select a server"
          puts "(you could connect to multible server if you run awsssh in tmux)"
          print "Server numer (Enter to exit): "
        end
        server_selection = STDIN.gets.chomp.split(",").map{|n| n.strip.to_i if n.strip.to_i != 0}
        server_to_connect = server_selection.reject{ |a| a.nil? || a > server_list.length+1}
        if server_to_connect.length > 1 && check_in_tmux
          session = "awsssh-connect"
          `tmux -2 new-session -d -s #{session}`
          server_to_connect.each_with_index do |server, index|
            puts "connect to #{server_list[server]}"
            `tmux send -t #{session} "ssh #{server_list[server]}" ENTER`
            # `tmux send -t #{session} "ls -la" ENTER`
            `tmux split-window -t #{session}:.1`
            `tmux select-layout -t #{session} tiled`
          end
          `tmux send -t #{session} "exit" ENTER`
          `tmux set-window-option -t #{session} synchronize-panes on`
          `tmux select-window -t #{session}:1`
          `tmux switch -t #{session}`
        elsif server_to_connect.length == 1
          puts "connect one to #{server_list[server_to_connect.first]}"
          connect_server server_list[server_to_connect.first]
        else
          puts "No Server sellected"
          puts
          break
        end
        exit 0
      end
    end

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

    ##
    # connect to server via system ssh
    # @since 3.1.0
    # @param hostname [String] Server hostname or ssh conf alias
    #
    def connect_server(hostname)
      exec "ssh #{hostname}"
      exit 0
    end

    ##
    # check for updates every 2h and display a message if there is a newer version
    # @since 3.1.1
    #
    def check_version
      temp_file = "/tmp/awsssh_version_check"
      if File.exists?(temp_file)
        if ((Time.now - File.mtime(temp_file)) / (60 * 60 * 2)).to_i != 0 # check all 2h
          check = true
        else
          check = false
        end
      else
        check = true
      end
      if check
        begin
          rubygems = JSON.parse(open("https://rubygems.org/api/v1/versions/awsssh/latest.json").read)
          if rubygems["version"] != VERSION
            puts "   ############################################".colorize(:red)
            puts "   # You're using an old version of this gem! #".colorize(:red)
            puts "   # Run `gem update awsssh`                  #".colorize(:red)
            puts "   ############################################".colorize(:red)
            puts
          end
        rescue
        ensure
          FileUtils.touch(temp_file)
        end
      end
    end

    ##
    # Check if is in TMUX env
    # @since 3.2.0
    # @return [Boolean] in TMUX or not
    def check_in_tmux
      !ENV['TMUX'].nil?
    end
  end
end
