Gem::Specification.new do |s|
  s.name        = 'awsssh'
  s.version     = '2.1.0'
  s.date        = '2014-02-27'
  s.summary     = "Connects you with OpsWorks EC2"
  s.description = "This will connects you with an EC3 instace"
  s.authors     = ["Sebastian Thiele"]
  s.email       = [%w(Sebastian.Thiele infopark.de).join('@')]
  s.license     = "MIT"
  s.files       = `git ls-files`.split("\n")
  s.executables = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.homepage    = "https://github.com/infopark/support/tree/master/scripte/ruby/awsssh"


  s.add_runtime_dependency "net-ssh", "2.7.0"
  s.add_runtime_dependency "inifile", "2.0.2"
  s.add_runtime_dependency "aws-sdk", "1.35.0,"
end