# Cookbook Name:: hadoop
#
# Resource:: resourcemanager
#

actions :add, :remove, :register, :deregister
default_action :add

attribute :memory_kb, :kind_of => Integer, :default => 8388608 #CHECK
