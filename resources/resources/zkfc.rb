# Cookbook Name:: hadoop
#
# Resource:: zkfc
#

actions :add, :remove, :register, :deregister
default_action :add

attribute :memory_kb, :kind_of => Integer, :default => 8388608 #CHECK
attribute :parent_log_dir, :kind_of => String, :default => "/var/log/hadoop"
attribute :suffix_log_dir, :kind_of => String, :default => "zkfc"
