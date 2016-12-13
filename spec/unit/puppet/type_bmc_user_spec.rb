#!/usr/bin/env rspec
#
require 'spec_helper'

type_class = Puppet::Type.type(:bmc_user)
provider_class = type_class.provider(:ipmitoo)

describe type_class do
  let(:type) do
    Puppet::Type.type(:bmc_user).new(
        :name => 'root',
        :password => 'calvin',
        :enable => true,
        :privilege => 'ADMINISTRATOR',
        :channel => 1,
        :provider => 'ipmitool'
    )
  end

  let(:provider) do
    provider_class.new
  end
  subject do
    provider.resource = type
    type
  end

  it 'exceptions handling' do
    expect {
      Puppet::Type.type(:bmc_user).new(
          :name => 'foo',
          :password => 'theSecret',
          :privilege => 'XXXXX'
      ) }.to raise_error(Puppet::ResourceError)

  end
end
