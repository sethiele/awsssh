
desc 'install awsssh'
task :install do
  puts "Install gems"
  `bundle --quiet`
  puts "create link in /usr/local/bin"
  `ln -s #{File.dirname(__FILE__)}/awsssh.rb /usr/local/bin/awsssh`
  puts "Done... run $ awsssh hostname"
end

task :default => :install
