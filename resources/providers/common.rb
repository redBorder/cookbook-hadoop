# Cookbook Name:: hadoop
#
# Provider:: common
#

action :add do #Usually used to install and configure something
  begin
    name = new_resource.name
    zookeeper_hosts = new_resource.zookeeper_hosts
    yarnMemory = new_resource.yarnMemory
    containersMemory = new_resource.containersMemory
    link_conf_folder = new_resource.link_conf_folder
    log_parent_folder = new_resource.log_parent_folder
    cdomain = node["redborder"]["cdomain"]
    conf_folder = "/usr/lib/hadoop/etc/hadoop"

    ##########################
    #HADOOP INSTALLATION
    ##########################
    
    yum_package "hadoop" do
      action :upgrade
      flush_cache [:before]
    end

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

    ###################################
    # DIRECTORY STRUCTURE CREATION
    ##################################

    link link_conf_folder do
      to conf_folder
      link_type :symbolic
    end
 
    directory log_parent_folder do 
      owner "hadoop"
      group "hadoop"
      mode 0755
    end
 
    directory "/var/lib/hadoop" do
      owner "hadoop"
      group "hadoop"
      mode 755
    end

    ####################
    # TEMPLATES
    ####################

    template "#{conf_folder}/core-site.xml" do
        source "hadoop_core-site.xml.erb"
        owner "root"
        group "root"
        cookbook "hadoop"
        mode 0644
        retries 2
        variables(:zk_hosts => zookeeper_hosts)
        notifies node["redborder"]["services"]["hadoop-resourcemanager"] ? :restart : :nothing, 'service[hadoop-resourcemanager]', :delayed
        notifies node["redborder"]["services"]["hadoop-nodemanager"] ? :restart  : :nothing, 'service[hadoop-nodemanager]', :delayed
    end

    template "#{conf_folder}/yarn-site.xml" do
       source "hadoop_yarn-site.xml.erb"
       owner "root"
       group "root"
       cookbook "hadoop"
       mode 0644
       retries 2
       variables(:name => name,
                 :zk_hosts => zookeeper_hosts,
                 :resourcemanager_managers => node["redborder"]["managers_per_services"]["hadoop-resourcemanager"],
                 :cdomain => cdomain,
                 :yarnMemory => yarnMemory,
                 :containersMemory => containersMemory)
       notifies node["redborder"]["services"]["hadoop-nodemanager"] ? :restart : :nothing, 'service[hadoop-nodemanager]', :delayed
       notifies node["redborder"]["services"]["hadoop-resourcemanager"] ? :restart : :nothing, 'service[hadoop-resourcemanager]', :delayed
    end
    Chef::Log.info("Hadoop cookbook (common) has been processed")
  rescue => e
    Chef::Log.error(e.message)
  end
end

action :remove do
  begin
    link_conf_folder = new_resource.link_conf_folder
    log_parent_folder = new_resource.log_parent_folder

    yum_package 'hadoop' do
      action :remove
    end

    link link_conf_folder do
      action :delete
    end

    directory log_parent_folder do
      recursive true
      action :delete
    end

    directory "/var/lib/hadoop" do
      recursive true
      action :delete
    end    
 
  #TODO: Hadoop uninstall
    Chef::Log.info("Hadoop cookbook (common) has been processed")
  rescue => e
    Chef::Log.error(e.message)
  end
end
