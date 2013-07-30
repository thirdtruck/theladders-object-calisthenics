$:.unshift(File.join(File.dirname(__FILE__), '..', '..', 'lib'))

require 'labels'

describe Name do
  it "should match Names created from the same String" do
    name1 = Name.new("Jane Smith")
    name2 = Name.new("Jane Smith")

    name1.same_name?(name2).should be_true
  end
end

describe IDNumber do
  it "should initialize with a String for the ID" do
    idnumber = IDNumber.new("ID0001")

    idnumber.should be
  end

  it "should convert to a String" do
    idnumber = IDNumber.new("ID0001")

    idnumber.to_s.should == "ID0001"
  end

  it "should match IDNumbers created from the same String" do
    idnumber1 = IDNumber.new("ID0001")
    idnumber2 = IDNumber.new("ID0001")

    idnumber1.same_id?(idnumber2).should be_true
  end

  it "should not match IDNumbers created from different Strings" do
    idnumber1 = IDNumber.new("ID0001")
    idnumber2 = IDNumber.new("ID9999")

    idnumber1.same_id?(idnumber2).should be_false
  end
end

describe PersonIdentity do
  it "should initialize with a Name and an IDNumber" do
    name = Name.new("Jane Smith")
    idnumber = IDNumber.new("ID0001")

    identity = PersonIdentity.new(name: name, idnumber: idnumber)

    identity.should be
  end

  it "should convert to a String" do
    name = Name.new("Jane Smith")
    idnumber = IDNumber.new("ID0001")

    identity = PersonIdentity.new(name: name, idnumber: idnumber)

    identity.to_s.should == "Name: Jane Smith\nID Number: ID0001"
  end
end
