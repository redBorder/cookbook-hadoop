# Cookbook Name:: hadoop
#
# Resource:: nodemanager
#

actions :add, :remove, :register, :deregister
default_action :add

attribute :memory_kb, :kind_of => Integer, :default => 8388608 #CHECK
attribute :log_parent_folder, :kind_of => String, :default => "/var/log/hadoop"

