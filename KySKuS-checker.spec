Name:           KySKuS-checker
Version:        1.0
Release:        1%{?dist}
Summary:        File integrity monitor for Fedora
License:        MIT
Requires:       coreutils, diffutils
BuildArch:      noarch

Source0: check.sh
Source1: KySKuS-checker
Source2: check.service
Source3: KySKuS-checker.conf

%install
mkdir -p %{buildroot}/usr/local/bin
mkdir -p %{buildroot}/usr/lib/systemd/system
mkdir -p %{buildroot}/etc

install -m 0755 %{SOURCE0} %{buildroot}/usr/local/bin/check.sh
install -m 0755 %{SOURCE1} %{buildroot}/usr/local/bin/KySKuS-checker
install -m 0644 %{SOURCE2} %{buildroot}/usr/lib/systemd/system/check.service
install -m 0644 %{SOURCE3} %{buildroot}/etc/KySKuS-checker.conf

%files
%attr(0755,root,root) /usr/local/bin/check.sh
%attr(0755,root,root) /usr/local/bin/KySKuS-checker
%attr(0644,root,root) /usr/lib/systemd/system/check.service
%config(noreplace) /etc/KySKuS-checker.conf

%post
chmod 600 /etc/KySKuS-checker.conf
chown root:root /etc/KySKuS-checker.conf
systemctl daemon-reload

%postun
if [ $1 -eq 0 ]; then
    systemctl --no-reload disable check.service >/dev/null 2>&1 || :
fi
