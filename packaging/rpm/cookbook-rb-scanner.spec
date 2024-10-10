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
if [ -d /var/chef/cookbooks/rb-scanner ]; then
    rm -rf /var/chef/cookbooks/rb-scanner
fi

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

%postun
# Deletes directory when uninstall the package
if [ "$1" = 0 ] && [ -d /var/chef/cookbooks/rb-scanner ]; then
  rm -rf /var/chef/cookbooks/rb-scanner
fi

%files
%defattr(0755,root,root)
/var/chef/cookbooks/rb-scanner
%defattr(0644,root,root)
/var/chef/cookbooks/rb-scanner/README.md

%doc

%changelog
* Thu Oct 10 2024 Miguel Negrón <manegron@redborder.com>
- Add pre and postun

* Mon May 22 2023 Luis J. Blanco Mier <ljblanco@redborder.com>
- parent_id removed from sensor info. Nodes are self aware of either manager or proxy

* Wed Dec 01 2021 Javier Rodriguez <javiercrg@redborder.com>
- first spec version
