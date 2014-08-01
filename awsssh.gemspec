Gem::Specification.new do |s|
  s.name        = 'awsssh'
  s.version     = '2.1.2'
  s.date        = '2014-08-01'
  s.summary     = "Connects you with OpsWorks EC2"
  s.description = "This will connects you with an EC2 instace"
  s.authors     = ["Sebastian Thiele"]
  s.email       = [%w(Sebastian.Thiele infopark.de).join('@')]
  s.license     = "MIT"
  s.files       = `git ls-files`.split("\n")
  s.executables = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.homepage    = "https://github.com/sethiele/awsssh"


  s.add_runtime_dependency "net-ssh", "2.7.0"
  s.add_runtime_dependency "inifile", "2.0.2"
  s.add_runtime_dependency "aws-sdk", "1.35.0"
  s.add_runtime_dependency "thor", "0.18.1"
end
