%w{openjdk-6-jdk libyaml-dev libxslt1-dev}.each do |pkgs|
  package pkgs do
    action :install
  end
end

execute "install_elasticsearch" do
  command "dpkg -i /tmp/elasticsearch-0.90.7.deb"
  action :nothing
end

remote_file "/tmp/elasticsearch-0.90.7.deb" do
  source "https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-0.90.7.deb"
  notifies :run, "execute[install_elasticsearch]", :immediately
  not_if {File.exists?("/usr/share/elasticsearch")}
end

service "elasticsearch" do
  supports :status => true, :restart => true, :start => true
end

execute "install_elasticsearch_head" do
  command "/usr/share/elasticsearch/bin/plugin -install mobz/elasticsearch-head"
  not_if {File.exists?("/usr/share/elasticsearch/plugins/head")}
  notifies :restart, resources(:service => "elasticsearch")
end

execute "install_libssl" do
  command "dpkg -i /tmp/libssl0.9.8_0.9.8o-4squeeze14_amd64.deb"
  action :nothing
end

remote_file "/tmp/libssl0.9.8_0.9.8o-4squeeze14_amd64.deb" do
  source "http://ftp.us.debian.org/debian/pool/main/o/openssl/libssl0.9.8_0.9.8o-4squeeze14_amd64.deb"
  notifies :run, "execute[install_libssl]", :immediately
  not_if {File.exists?("/usr/lib/libssl.so.0.9.8")}
end

execute "install_td-agent" do
  command "dpkg -i /tmp/td-agent_1.1.17-1_amd64.deb"
  action :nothing
end

remote_file "/tmp/td-agent_1.1.17-1_amd64.deb" do
  source "http://packages.treasure-data.com/debian/pool/contrib/t/td-agent/td-agent_1.1.17-1_amd64.deb"
  notifies :run, "execute[install_td-agent]", :immediately
  not_if {File.exists?("/usr/lib/fluent/ruby/bin/gem")}
end

%w{fluent-plugin-elasticsearch fluent-plugin-typecast}.each do |gems|
  gem_package gems do
    gem_binary("/usr/lib/fluent/ruby/bin/gem")
    options("--no-ri --no-rdoc") 
    only_if {File.exists?("/usr/lib/fluent/ruby/bin/gem")}
  end
end

service "td-agent" do
  action :nothing
  supports :status => true, :restart => true, :start => true
end

template "/etc/td-agent/td-agent.conf" do
  source "td-agent.conf.erb"
  owner "root"
  group "root"
  mode "00644"
  notifies :restart, "service[td-agent]"
end
