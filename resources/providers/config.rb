action :add do
  begin

    # install package
    yum_package "redborder-scanner" do
      action :install
      flush_cache [ :before ]
    end

    user user do
      action :create
    end

    directory "/usr/share/redborder-scanner/conf" do
      owner "root"
      group "root"
      mode 0700
      action :create
    end

    link "/etc/redborder-scanner" do
      to "/usr/share/redborder-scanner/conf"
    end if !File.exists?"/etc/redborder-scanner"

    template "/etc/sysconfig/rb-scanner-request" do
      source "rb-scanner-request_sv.erb"
      owner "root"
      group "root"
      mode 0644
      retries 2
      notifies :restart, "service[redborder-scanner]", :delayed
    end

    template "/usr/share/rb-scanner-request/conf/config.json" do
      source "rb-scanner-request_config.json.erb"
      owner "root"
      group "root"
      mode 0644
      retries 2
      variables(:scanner_nodes => scanner_nodes)
      notifies :restart, "service[redborder-scanner]", :delayed
    end

    service "redborder-scanner" do
      service_name "redborder-scanner"
      ignore_failure true
      supports :status => true, :restart => true, :enable => true
      action [:start, :enable]
    end

    Chef::Log.info("redborder-scanner has been configured correctly.")
  rescue => e
    Chef::Log.error(e.message)
  end
end

action :remove do
  begin

    logdir = new_resource.logdir

    service "redborder-scanner" do
      ignore_failure true
      supports :status => true, :enable => true
      action [:stop, :disable]
    end

    %w[ /etc/redborder-scanner].each do |path|
      directory path do
        recursive true
        action :delete
      end
    end
    # uninstall package
    yum_package "redborder-scanner" do
     action :remove
    end
    #
    Chef::Log.info("redborder-scanner has been deleted correctly.")
  rescue => e
    Chef::Log.error(e.message)
  end
end


action :register do #Usually used to register in consul
  begin
    if !node["redborder-scanner"]["registered"]
      query = {}
      query["ID"] = "redborder-scanner-#{node["hostname"]}"
      query["Name"] = "redborder-scanner"
      query["Address"] = "#{node["ipaddress"]}"
      query["Port"] = 443
      json_query = Chef::JSONCompat.to_json(query)

      execute 'Register service in consul' do
        command "curl http://localhost:8500/v1/agent/service/register -d '#{json_query}' &>/dev/null"
        action :nothing
      end.run_action(:run)

      node.set["redborder-scanner"]["registered"] = true
    end
    Chef::Log.info("redborder-scanner service has been registered in consul")
  rescue => e
    Chef::Log.error(e.message)
  end
end

action :deregister do #Usually used to deregister from consul
  begin
    if node["redborder-scanner"]["registered"]
      execute 'Deregister service in consul' do
        command "curl http://localhost:8500/v1/agent/service/deregister/redborder-scanner-#{node["hostname"]} &>/dev/null"
        action :nothing
      end.run_action(:run)

      node.set["redborder-scanner"]["registered"] = false
    end
    Chef::Log.info("redborder-scanner service has been deregistered from consul")
  rescue => e
    Chef::Log.error(e.message)
  end
end
