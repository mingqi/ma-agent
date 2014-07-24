%define        __spec_install_post %{nil}
%define          debug_package %{nil}
%define        __os_install_post %{_dbpath}/brp-compress
%define 	   _topdir /home/vagrant/monitorat/ma-agent/_build/rpmbuild

Summary: ma-agent
Name: ma-agent
Version: 1.0.0
License: APL2
Release: 0%{?dist}

Group: System Environment/Daemons
Vendor: Monitor@, Inc.
URL: http://monitorat.com/
SOURCE0: %{name}-%{version}.tar.gz
#Source1: %{name}.init
BuildRoot: /var/tmp/ma-agent/rpmbuild/BUILDROOT

#Requires: /sbin/chkconfig
#Requires(post): /sbin/chkconfig
#Requires(post): /sbin/service
#Requires(preun): /sbin/chkconfig
#Requires(preun): /sbin/service

%description
%{summary}

%prep
%setup -q

%build
# Empty section.

%install
rm -rf %{buildroot}
mkdir -p  %{buildroot}

# in builddir
cp -a * %{buildroot}


%clean
rm -rf %{buildroot}

%post
echo "Configure ma-agent to start, when booting up the OS..."
/sbin/chkconfig --add ma-agent

%preun
echo "Stopping ma-agent ..."
/sbin/service ma-agent stop >/dev/null 2>&1 || :
/sbin/chkconfig --del ma-agent

%files
%defattr(-,root,root,-)
/etc/ma-agent/ma-agent.conf
/etc/init.d/ma-agent
/opt/ma-agent/*

