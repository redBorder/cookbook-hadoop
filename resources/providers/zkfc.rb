# Cookbook Name:: hadoop
#
# Provider:: zkfc
#

action :add do
  begin
    memory_kb = new_resource.memory_kb

    template "/etc/sysconfig/hadoop_zkfc" do
      source "hadoop_zkfc_sysconfig.erb"
      owner "root"
      group "root"
      cookbook "hadoop"
      mode 0644
      retries 2
      variables(:memory_kb => memory_kb)
      notifies :restart, 'service[hadoop-zkfc]', :delayed
    end

     Chef::Log.info("Hadoop Zkfc cookbook has been processed")
  rescue => e
    Chef::Log.error(e.message)
  end
end

action :remove do
    parent_config_dir = "/etc/hadoop"
    config_dir = "#{parent_config_dir}/zkfc"
    parent_log_dir = new_resource.parent_log_dir
    suffix_log_dir = new_resource.suffix_log_dir
    log_dir = "#{parent_log_dir}/#{suffix_log_dir}"

    service "hadoop-zkfc" do
      supports :status => true, :start => true, :restart => true, :reload => true
      action [:disable,:stop]
    end

    dir_list = [
                 config_dir,
                 log_dir
               ]

    # removing directories
    dir_list.each do |dirs|
      directory dirs do
        action :delete
        recursive true
      end
    end

    Chef::Log.info("Hadoop zkfc cookbook has been processed")
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
