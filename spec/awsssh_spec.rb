require "awsssh"
describe Awsssh::Awsssh do
  def runner(options = {})
    @runner ||= Awsssh::Awsssh.new([1], options, :destination_root => destination_root)
  end

  def action(*args, &block)
    capture(:stdout) { runner.send(*args, &block) }
  end

  describe "on list stacks" do
    it "lists all stacks" do
      base = Awsssh::Awsssh.new ["-s"]
      base.send(:list_stacks, 'trox').class.should eq [].class
    end
  end
end