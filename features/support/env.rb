ENV['PATH'] = "#{File.expand_path(File.dirname(__FILE__) + '/../../bin')}#{File::PATH_SEPARATOR}#{ENV['PATH']}"
ENV['AWS_CREDENTIAL_FILE'] = "credentials"

require 'aruba/cucumber'
