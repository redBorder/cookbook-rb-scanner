# default attributes
default['redborder-scanner']['registered'] = false
default['redborder-scanner']['is_nmap_installed'] = File.exist?('/usr/bin/nmap')
