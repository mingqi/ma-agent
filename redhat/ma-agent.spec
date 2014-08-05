%define        __spec_install_post %{nil}
%define          debug_package %{nil}
%define        __os_install_post %{_dbpath}/brp-compress
%define 	   _topdir %(echo $PWD)/

Summary: ma-agent
Name: ma-agent
Version: 1.0.0
License: APL2
Release: 1

Group: System Environment/Daemons
Vendor: Monitor@, Inc.
URL: http://monitorat.com/
SOURCE0: %{name}-%{version}.tar.gz
#Source1: %{name}.init
BuildRoot: /var/tmp/ma-agent/rpmbuild/BUILDROOT

Requires: /usr/sbin/useradd /usr/sbin/groupadd
Requires: /sbin/chkconfig
Requires(post): /sbin/chkconfig
Requires(post): /sbin/service
Requires(preun): /sbin/chkconfig
Requires(preun): /sbin/service

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
echo "adding 'ma-agent-ro' group..."
getent group ma-agent-ro >/dev/null || /usr/sbin/groupadd  ma-agent-ro
echo "adding 'ma-agent-ro' user..."
getent passwd ma-agent-ro >/dev/null || \
  /usr/sbin/useradd -g ma-agent-ro -s /bin/bash -c 'ma-agent-ro' ma-agent-ro

%preun
echo "Stopping ma-agent ..."
/sbin/service ma-agent stop >/dev/null 2>&1 || :
/sbin/chkconfig --del ma-agent

%files
%defattr(-,root,root,-)
/etc/ma-agent/*
/etc/init.d/ma-agent
/opt/ma-agent/*

