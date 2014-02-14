
desc 'install awsssh'
task :install do
  puts "Install gems"
  `bundle --quiet`
  unless File.exist?("/usr/local/bin/awsssh")
    ln_s File.dirname(__FILE__) + "/awsssh.rb", "/usr/local/bin/awsssh"
    puts "Done... run $ awsssh"
  else
    puts "/usr/local/bin/awsssh allready exists"
  end
end

task :default => :install
