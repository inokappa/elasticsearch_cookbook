%w{nginx unzip}.each do |pkgs|
  package pkgs do
    action :install
  end
end

remote_file "/tmp/kibana-3.0.0milestone4.zip" do
  source "https://download.elasticsearch.org/kibana/kibana/kibana-3.0.0milestone4.zip"
  notifies :run, "execute[unpack_kibana]", :immediately
  not_if {File.exists?("/tmp/kibana-3.0.0milestone4.zip")}
end

service "nginx" do
  supports :status => true, :restart => true, :start => true
end

execute "unpack_kibana" do
  command "unzip /tmp/kibana-3.0.0milestone4.zip"
  not_if {File.exists?("/tmp/kibana-3.0.0milestone4.zip")}
end

bash "copy_to_webroot" do
  owner "root"
  cwd "/tmp"
  code <-EOH
    cp -rf /tmp/kibana-3.0.0milestone4 /usr/share/nginx/www/kibana
  EOH
  only_if {File.exists?("/tmp/kibana-3.0.0milestone4")} 
end
