# Cookbook Name:: hadoop
#
# Provider:: zkfc
#

action :add do
  begin


     template "PATH/template1" do
       source "template1.erb"
       cookbook "example"
       #...
     end

     Chef::Log.info("Hadoop Zkfc cookbook has been processed")
  rescue => e
    Chef::Log.error(e.message)
  end
end

action :remove do #Usually used to uninstall something
  begin
     # ... your code here ...
     Chef::Log.info("Hadoop Zkfc cookbook has been processed")
  rescue => e
    Chef::Log.error(e.message)
  end
end

action :register do
  begin
    if !node["hadoop"]["zkfc"]["registered"]
      query = {}
      query["ID"] = "hadoop-zkfc-#{node["hostname"]}"
      query["Name"] = "hadoop-zkfc"
      query["Address"] = "#{node["ipaddress"]}"
      query["Port"] = 8080 #CHANGE
      json_query = Chef::JSONCompat.to_json(query)

      execute 'Register service in consul' do
         command "curl http://localhost:8500/v1/agent/service/register -d '#{json_query}' &>/dev/null"
         action :nothing
      end.run_action(:run)

      node.set["hadoop"]["zkfc"]["registered"] = true
      Chef::Log.info("Hadoop Zkfc service has been registered to consul")
    end
  rescue => e
    Chef::Log.error(e.message)
  end
end

action :deregister do
  begin
    if node["hadoop"]["zkfc"]["registered"]
      execute 'Deregister service in consul' do
        command "curl http://localhost:8500/v1/agent/service/deregister/hadoop-zkfc-#{node["hostname"]} &>/dev/null"
        action :nothing
      end.run_action(:run)

      node.set["hadoop"]["zkfc"]["registered"] = false
      Chef::Log.info("Hadoop Zkfc service has been deregistered from consul")
    end
  rescue => e
    Chef::Log.error(e.message)
  end
end
