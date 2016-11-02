# Cookbook Name:: hadoop
#
# Provider:: common
#

action :add do #Usually used to install and configure something
  begin
    zookeeper_hosts = new_resource.zookeeper_hosts
    memory_kb_nodemanager = new_resource.memory_kb_nodemanager
    reservedStackMemory = new_resource.reservedStackMemory
    yarnMemory = new_resource.yarnMemory
    containersMemory = new_resource.containersMemory
    cdomain = node["redborder"]["cdomain"]

    template "/etc/hadoop/mapred-site.xml" do
        source "hadoop_mapred-site.xml.erb"
        owner "root"
        group "root"
        mode 0644
        retries 2
        variables(:key_id => s3_secrets['key_id'], :key_secret => s3_secrets['key_secret'],
                  :memory_kb_nodemanager => memory_kb_nodemanager )
        notifies node["redborder"]["services"]["hadoop-zkfc"] ? :restart : :nothing, 'service[hadoop-zkfc]', :delayed
    end

    template "/etc/hadoop/yarn-site.xml" do
       source "hadoop_yarn-site.xml.erb"
       owner "root"
       group "root"
       mode 0644
       retries 2
       variables(:zk_hosts => zookeeper_hosts,
                 :resourcemanager_managers => node["redborder"]["managers_per_services"]["hadoop-resourcemanager"],
                 :cdomain => cdomain, :yarnMemory => yarnMemory)
       notifies node["redborder"]["services"]["hadoop-nodemanager"] ? :restart : :nothing, 'service[hadoop-nodemanager]', :delayed
       notifies node["redborder"]["services"]["hadoop-resourcemanager"] ? :restart : :nothing, 'service[hadoop-resourcemanager]', :delayed
    end

    template "etc/hadoop/hadoop_yarn-env.sh" do
      source "hadoop_yarn-env.sh.erb"
      owner "root"
      group "root"
      mode 0644
      retries 2
    end

    Chef::Log.info("Hadoop cookbook (common) has been processed")
  rescue => e
    Chef::Log.error(e.message)
  end
end

action :remove do #Usually used to uninstall something
  begin
     # ... your code here ...
     Chef::Log.info("Hadoop cookbook (common) has been processed")
  rescue => e
    Chef::Log.error(e.message)
  end
end