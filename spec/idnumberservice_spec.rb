$:.unshift(File.join(File.dirname(__FILE__), '..', '..', 'lib'))
$:.unshift(File.join(File.dirname(__FILE__), '..', 'spec'))

describe IDNumberService do
  it "can be initialized" do
    IDNumberService.new
  end
end
