#
# Cookbook Name:: nova
# Recipe:: vncproxy
#
# Copyright 2009, Example Com
# Copyright 2011, Dell Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

include_recipe "nova::config"

pkgs=%w[python-numpy nova-console nova-consoleauth]
pkgs.each do |pkg|
  package pkg do
    action :upgrade
    options "--force-yes"
  end
end

if node[:nova][:use_novnc]
  package "novnc" do
    action :upgrade
    options "--force-yes"
  end
  service "novnc" do
    supports :status => true, :restart => true
    action [:enable, :start]
    subscribes :restart, resources(:template => "/etc/nova/nova.conf"), :delayed
  end
else
  package "nova-vncproxy" do
    action :upgrade
    options "--force-yes"
  end
  execute "Fix permission Bug" do
    command "sed -i 's/nova$/root/g' /etc/init/nova-vncproxy.conf"
    action :run
  end

  service "nova-vncproxy" do
    supports :status => true, :restart => true
    action [:enable, :start]
    subscribes :restart, resources(:template => "/etc/nova/nova.conf"), :delayed
  end
end

service "nova-consoleauth" do
  supports :status => true, :restart => true
  action [:enable, :start]
  subscribes :restart, resources(:template => "/etc/nova/nova.conf"), :delayed
end
