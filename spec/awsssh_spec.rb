require "awsssh"
describe Awsssh::Awsssh do
  def runner(options = {})
    @runner ||= Awsssh::Awsssh.new([1], options, :destination_root => destination_root)
  end

  def action(*args, &block)
    capture(:stdout) { runner.send(*args, &block) }
  end

  describe "on list porfiles" do
    it "should list all profiles" do
      base = Awsssh::Awsssh.new ["-s"]
      expect(base.send(:list_profiles).class).to eq [].class
    end
  end

  describe "on list server" do
    it "raise an error when no profile is set"

    it "lists all server" do
      base = Awsssh::Awsssh.new ["-s"]
      expect(base.send(:list_server, 'trox').class).to eq [].class
    end
  end
end
