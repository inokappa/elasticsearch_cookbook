%w{openjdk-7-jdk libyaml-dev libxslt1-dev}.each do |pkgs|
  package pkgs do
    action :install
  end
end

execute "install_elasticsearch" do
  command "dpkg -i /tmp/elasticsearch-1.0.0.RC2.deb"
  action :nothing
end

remote_file "/tmp/elasticsearch-1.0.0.RC2.deb" do
  source "https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-1.0.0.RC2.deb"
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

execute "install_elasticsearch_marvel" do
  command "/usr/share/elasticsearch/bin/plugin -install elasticsearch/marvel/latest"
  not_if {File.exists?("/usr/share/elasticsearch/plugins/marvel")}
  notifies :restart, resources(:service => "elasticsearch")
end

execute "install_elasticsearch_HQ" do
  command "/usr/share/elasticsearch/bin/plugin -install royrusso/elasticsearch-HQ"
  not_if {File.exists?("/usr/share/elasticsearch/plugins/HQ")}
  notifies :restart, resources(:service => "elasticsearch")
end

execute "install_elasticsearch_kuromoji" do
  command "/usr/share/elasticsearch/bin/plugin -install elasticsearch/elasticsearch-analysis-kuromoji/2.0.0.RC1"
  not_if {File.exists?("/usr/share/elasticsearch/plugins/analysis-kuromoji")}
  notifies :restart, resources(:service => "elasticsearch")
end
