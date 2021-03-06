Name: cookbook-hadoop
Version: %{__version}
Release: %{__release}%{?dist}
BuildArch: noarch
Summary: Hadoop cookbook to install and configure it in redborder environments

License: AGPL 3.0
URL: https://github.com/redBorder/cookbook-hadoop
Source0: %{name}-%{version}.tar.gz

%description
%{summary}

%prep
%setup -qn %{name}-%{version}

%build

%install
mkdir -p %{buildroot}/var/chef/cookbooks/hadoop
cp -f -r  resources/* %{buildroot}/var/chef/cookbooks/hadoop
chmod -R 0755 %{buildroot}/var/chef/cookbooks/hadoop
install -D -m 0644 README.md %{buildroot}/var/chef/cookbooks/hadoop/README.md

%pre

%post

%files
%defattr(0755,root,root)
/var/chef/cookbooks/hadoop
%defattr(0644,root,root)
/var/chef/cookbooks/hadoop/README.md


%doc

%changelog
* Wed Nov 02 2016 Carlos J. Mateos <cjmateos@redborder.com> - 1.0.0-1
- first spec version
