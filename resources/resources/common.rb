# Cookbook Name:: hadoop
#
# Resource:: common
#

actions :add, :remove
default_action :add

attribute :name, :kind_of => String, :default => "localhost"
attribute :zookeeper_hosts, :kind_of => String, :default => "zookeeper.service:2181"
attribute :memory_kb, :kind_of => Integer
attribute :containersMemory, :kind_of => Integer, :default => 2048
attribute :log_parent_folder, :kind_of => String, :default => "/var/log/hadoop"
attribute :link_conf_folder, :kind_of => String, :default => "/etc/hadoop"
