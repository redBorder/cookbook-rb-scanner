# Cookbook Name:: rbscanner
#
# Resource:: config
#
actions :add, :remove, :register, :deregister
default_action :add

attribute :cdomain, :kind_of => String, :default => "redborder.cluster"
attribute :managers_all, :kind_of => Array, :default => []
attribute :flow_nodes, :kind_of => Array, :default => []
