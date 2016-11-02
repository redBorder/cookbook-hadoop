# Cookbook Name:: hadoop
#
# Resource:: common
#

actions :add, :remove
default_action :add

attribute :zookeeper_hosts, :kind_of => String, :default => "zookeeper.service:2181"
attribute :memory_kb_nodemanager, :kind_of => Integer
attribute :reservedStackMemory, :kind_of => Integer
attribute :yarnMemory, :kind_of => Integer
attribute :containersMemory, :kind_of => Integer
