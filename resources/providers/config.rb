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

    service "redborder-scanner" do
      service_name "redborder-scanner"
      supports :status => true, :reload => true, :restart => true, :start => true, :enable => true
      action [:enable,:start]
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
      supports :stop => true
      action :stop
    end

    # uninstall package
    #yum_package "redborder-scanner" do
    #  action :purge
    #end
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
