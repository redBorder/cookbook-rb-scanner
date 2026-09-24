# Cookbook:: rbscanner
# Resource:: config
actions :add, :remove, :register, :deregister
default_action :add

attribute :cdomain, kind_of: String, default: 'redborder.cluster'
attribute :managers_all, kind_of: Array, default: []
attribute :scanner_nodes, kind_of: Array, default: []
attribute :rb_webui, kind_of: String, default: 'webui.service'
# Manager API token. The agent needs it to upload network topology snapshots,
# which create inventory records; the plain scan status callbacks do not use it.
attribute :auth_token, kind_of: String, default: ''
