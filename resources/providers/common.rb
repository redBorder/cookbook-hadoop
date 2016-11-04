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
    s3_bucket = new_resource.s3_bucket
    s3_access_key = new_resource.s3_access_key
    s3_secret_key = new_resource.s3_secret_key

    ####################
    # HADOOP SERVICES
    #################### 

    service "hadoop-nodemanager" do
      supports :status => true, :start => true, :restart => true, :reload => true
      action :nothing
    end

    service "hadoop-resourcemanager" do
      supports :status => true, :start => true, :restart => true, :reload => true
      action :nothing
    end

    service "hadoop-zkfc" do
      supports :status => true, :start => true, :restart => true, :reload => true
      action :nothing
    end

    ####################
    # READ DATABAGS
    ####################

    #Obtaining s3 data
    s3 = Chef::DataBagItem.load("passwords", "s3") rescue s3 = {}
    if !s3.empty?
      s3_bucket = s3["s3_bucket"]
      s3_access_key = s3["s3_access_key_id"]
      s3_secret_key = s3["s3_secret_key_id"]
    end

    ####################
    # TEMPLATES
    ####################

    template "/etc/hadoop/core-site.xml" do
        source "hadoop_core-site.xml.erb"
        owner "root"
        group "root"
        cookbook "hadoop"
        mode 0644
        retries 2
        variables(:zk_hosts => zookeeper_hosts)
        notifies node["redborder"]["services"]["hadoop-zkfc"] ? :restart : :nothing, 'service[hadoop-zkfc]', :delayed
    end

    template "/etc/hadoop/mapred-site.xml" do
        source "hadoop_mapred-site.xml.erb"
        owner "root"
        group "root"
        cookbook "hadoop"
        mode 0644
        retries 2
        variables(:containersMemory => containersMemory,
                  :memory_kb_nodemanager => memory_kb_nodemanager,
                  :cdomain => cdomain)
        notifies node["redborder"]["services"]["hadoop-zkfc"] ? :restart : :nothing, 'service[hadoop-zkfc]', :delayed
    end

    template "/etc/hadoop/yarn-site.xml" do
       source "hadoop_yarn-site.xml.erb"
       owner "root"
       group "root"
       cookbook "hadoop"
       mode 0644
       retries 2
       variables(:zk_hosts => zookeeper_hosts,
                 :resourcemanager_managers => node["redborder"]["managers_per_services"]["hadoop-resourcemanager"],
                 :cdomain => cdomain,
                 :yarnMemory => yarnMemory)
       notifies node["redborder"]["services"]["hadoop-nodemanager"] ? :restart : :nothing, 'service[hadoop-nodemanager]', :delayed
       notifies node["redborder"]["services"]["hadoop-resourcemanager"] ? :restart : :nothing, 'service[hadoop-resourcemanager]', :delayed
    end

    [ "configuration.xsl", "container-executor.cfg", "capacity-scheduler.xml", "hadoop_fair-scheduler.xml",
      "hadoop-metrics.properties", "hadoop-metrics2.properties", "hadoop-policy.xml", "log4j.properties",
      "mapred-queues.xml", "hadoop-env.sh", "mapred-env.sh", "yarn-env.sh" ].each do |t|
    template "/opt/rb/etc/hadoop/#{t}" do
        source "hadoop_#{t}.erb"
        owner "root"
        group "root"
        cookbook "hadoop"
        mode 0644
        retries 2
      end
    end

    Chef::Log.info("Hadoop cookbook (common) has been processed")
  rescue => e
    Chef::Log.error(e.message)
  end
end

action :remove do
  begin
    parent_config_dir = "/etc/hadoop"
    parent_log_dir = new_resource.parent_log_dir

    directory "#{parent_config_dir}" do
      recursive true
      action :delete
    end

    # Remove parent log directory if it doesn't have childs
    delete_if_empty(parent_log_dir)

    Chef::Log.info("Hadoop cookbook (common) has been processed")
  rescue => e
    Chef::Log.error(e.message)
  end
end
