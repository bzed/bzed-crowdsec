# frozen_string_literal: true

require 'spec_helper'
require 'facter'
require 'facter/crowdsec'

describe :crowdsec, type: :fact do
  subject(:fact) { Facter.fact(:crowdsec) }

  # Mocking Facts
  # You will most likely need to mock other facts if your custom fact relies up on them
  # You can mock a existing core fact via:
  #  allow(Facter.fact(:fqdn)).to receive(:value).and_return('test.example.com')
  #  allow(Facter).to receive(:value).with(:fqdn).and_return('test.example.com')
  # This all depends on how you utilize it in the fact code

  # If you need to Mock a custom fact or non core fact you will first need to add that fact
  # by requiring the facter file ie. require facter/ec2_metadata
  # Or via code in the before each block:
  # before :each do
  #   Facter.add(:ec2_metadata) {}
  # Once the custom fact is added, you can mock like
  # allow(Facter.fact(:ec2_metadata)).to receive(:value).and_return({'42'})
  # allow(Facter).to receive(:value).with(:fqdn).and_return('test.example.com')
  # This all depends on how you utilize it in the fact code
  # This mock will go inside your test block or the before each block

  # Mocking confine example
  # confine kernel: 'Linux' (Located in Fact)
  # allow(Facter.fact(:kernel)).to receive(:value).and_return('Linux')

  # Using and Mocking Exec
  # You should always use the Facter Exectution method to execute commands on a system
  # This will allow you to easily mock items as a result
  # Facter::Core::Execution.execute('uname 2>&1')
  # allow(Facter::Core::Execution).to receive(:execute).with('uname 2>&1').and_return('Linux')

  before :each do
    # perform any action that should be run before every test
    Facter.clear
    # Facter.add(:ec2_metadata) {}
    # allow(Facter).to receive(:value).with(:fqdn).and_return('test.example.com')
    # allow(Facter).to receive(:value).with(:fqdn).and_return('test.example.com')
    # allow(Facter.fact(:ec2_metadata)).to receive(:value).and_return({'42'})
  end

  it 'returns a value' do
    expect(fact.value).to eq(nil)
  end
end
