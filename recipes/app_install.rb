package "openjdk-6-jdk" do
  action :install
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
