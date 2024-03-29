# Cookbook Name:: hadoop
#
# Provider:: resourcemanager
#

action :add do
  begin
     memory_kb = new_resource.memory_kb

     template "/etc/sysconfig/hadoop_resourcemanager" do
       source "hadoop_resourcemanager_sysconfig.erb"
       owner "root"
       group "root"
       cookbook "hadoop"
       mode 0644
       retries 2
       variables(:memory_kb => memory_kb)
       notifies :restart, 'service[hadoop-resourcemanager]', :delayed
     end

     service "hadoop-resourcemanager" do
       supports :status => true, :start => true, :restart => true, :reload => true
       action [:enable,:start]
     end

     Chef::Log.info("Hadoop ResourceManager cookbook has been processed")
  rescue => e
    Chef::Log.error(e.message)
  end
end

action :remove do
  begin
    parent_log_dir = new_resource.parent_log_dir
    suffix_log_dir = new_resource.suffix_log_dir
    log_dir = "#{parent_log_dir}/#{suffix_log_dir}"

    service "hadoop-resourcemanager" do
      supports :status => true, :start => true, :restart => true
      action [:disable,:stop]
    end

    # Cleaning log directory
    #directory log_dir do
    #  action :delete
    #  recursive true
    #end

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
      query["Port"] = 8021
      json_query = Chef::JSONCompat.to_json(query)

      execute 'Register service in consul' do
         command "curl http://localhost:8500/v1/agent/service/register -d '#{json_query}' &>/dev/null"
         action :nothing
      end.run_action(:run)

      node.normal["hadoop"]["resourcemanager"]["registered"] = true
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

      node.normal["hadoop"]["resourcemanager"]["registered"] = false
      Chef::Log.info("Hadoop ResourceManager service has been deregistered from consul")
    end
  rescue => e
    Chef::Log.error(e.message)
  end
end
