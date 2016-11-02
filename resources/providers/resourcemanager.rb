# Cookbook Name:: hadoop
#
# Provider:: resourcemanager
#

action :add do #Usually used to install and configure something
  begin
     # ... your code here ...

     template "PATH/template1" do
       source "template1.erb"
       cookbook "example"
       #...
     end

     Chef::Log.info("Hadoop ResourceManager cookbook has been processed")
  rescue => e
    Chef::Log.error(e.message)
  end
end

action :remove do #Usually used to uninstall something
  begin
     # ... your code here ...
     Chef::Log.info("Hadoop ResourceManager cookbook has been processed")
  rescue => e
    Chef::Log.error(e.message)
  end
end

action :register do
  begin
    if !node["hadoop"]["resourcemanager"]["registered"]
      query = {}
      query["ID"] = "hadoop-resourcemanager-#{node["hostname"]}"
      query["Name"] = "hadoop-resourcemanager"
      query["Address"] = "#{node["ipaddress"]}"
      query["Port"] = 8080 #CHANGE
      json_query = Chef::JSONCompat.to_json(query)

      execute 'Register service in consul' do
         command "curl http://localhost:8500/v1/agent/service/register -d '#{json_query}' &>/dev/null"
         action :nothing
      end.run_action(:run)

      node.set["hadoop"]["resourcemanager"]["registered"] = true
      Chef::Log.info("Hadoop ResourceManager service has been registered to consul")
    end
  rescue => e
    Chef::Log.error(e.message)
  end
end

action :deregister do
  begin
    if node["hadoop"]["resourcemanager"]["registered"]
      execute 'Deregister service in consul' do
        command "curl http://localhost:8500/v1/agent/service/deregister/hadoop-resourcemanager-#{node["hostname"]} &>/dev/null"
        action :nothing
      end.run_action(:run)

      node.set["hadoop"]["resourcemanager"]["registered"] = false
      Chef::Log.info("Hadoop ResourceManager service has been deregistered from consul")
    end
  rescue => e
    Chef::Log.error(e.message)
  end
end
