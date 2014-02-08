require 'serverspec'

include Serverspec::Helper::Exec
include Serverspec::Helper::DetectOS

RSpec.configure do |c|
  c.before :all do
    c.path = '/sbin:/usr/sbin'
  end
end

describe package('elasticsearch') do
  it { should be_installed }
end

describe process('java') do
  it { should be_running }
  its(:args) { should match /elasticsearch/ }
end

describe command('/usr/share/elasticsearch/bin/plugin -l | egrep \'head|marvel|HQ|kuromoji\'') do
  it { should return_exit_status 0 }
end
