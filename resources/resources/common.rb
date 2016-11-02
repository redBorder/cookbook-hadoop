# Cookbook Name:: hadoop
#
# Resource:: common
#

actions :add, :remove
default_action :add

attribute :zookeeper_hosts, :kind_of => String, :default => "zookeeper.service:2181"
attribute :reservedStackMemory, :kind_of => Integer
attribute :yarnMemory, :kind_of => Integer
attribute :containersMemory, :kind_of => Integer
