Name: cookbook-rb-scanner
Version: %{__version}
Release: %{__release}%{?dist}
BuildArch: noarch
Summary: Redborder-scanner cookbook to install and configure it in redborder environments

License: AGPL 3.0
URL: https://github.com/redBorder/cookbook-rb-scanner
Source0: %{name}-%{version}.tar.gz

%description
%{summary}

%prep
%setup -qn %{name}-%{version}

%build

%install
mkdir -p %{buildroot}/var/chef/cookbooks/rb-scanner
cp -f -r  resources/* %{buildroot}/var/chef/cookbooks/rb-scanner/
chmod -R 0755 %{buildroot}/var/chef/cookbooks/rb-scanner
install -D -m 0644 README.md %{buildroot}/var/chef/cookbooks/rb-scanner/README.md

%pre

%post
case "$1" in
  1)
    # This is an initial install.
    :
  ;;
  2)
    # This is an upgrade.
    su - -s /bin/bash -c 'source /etc/profile && rvm gemset use default && env knife cookbook upload rbscanner'
  ;;
esac

%files
%defattr(0755,root,root)
/var/chef/cookbooks/rb-scanner
%defattr(0644,root,root)
/var/chef/cookbooks/rb-scanner/README.md

%doc

%changelog
* Mon May 22 2023 Luis J. Blanco Mier <ljblanco@redborder.com> - 0.0.2-1
- parent_id removed from sensor info. Nodes are self aware of either manager or proxy
* Wed Dec 01 2021 Javier Rodriguez <javiercrg@redborder.com> - 0.0.1-1
- first spec version
