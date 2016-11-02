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
attribute :s3_bucket, :kind_of => String
attribute :s3_access_key, :kind_of => String
attribute :s3_secret_key, :kind_of => String
attribute :parent_log_dir, :kind_of => String, :default => "/var/log/hadoop"
