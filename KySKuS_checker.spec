Name:           KySKuS_checker
Version:        1.0
Release:        1%{?dist}
Summary:        Advanced file integrity monitor with CLI and diff logging
License:        MIT
Requires:       coreutils, diffutils
BuildArch:      noarch

Source0: check.sh
Source1: kyskus-checker
Source2: check.service

%description
Monitors critical system files and logs changes to journald.
Features:
- Custom intervals and file lists
- CLI configuration tool
- Shows file owner and diff of changes
- Autostart control

%install
mkdir -p %{buildroot}/usr/local/bin
mkdir -p %{buildroot}/usr/lib/systemd/system

install -m 0755 %{SOURCE0} %{buildroot}/usr/local/bin/check.sh
install -m 0755 %{SOURCE1} %{buildroot}/usr/local/bin/kyskus-checker
install -m 0644 %{SOURCE2} %{buildroot}/usr/lib/systemd/system/check.service

%files
%attr(0755,root,root) /usr/local/bin/check.sh
%attr(0755,root,root) /usr/local/bin/kyskus-checker
%attr(0644,root,root) /usr/lib/systemd/system/check.service
%config(noreplace) /etc/KySKuS_checker.conf

%post
chmod 600 /etc/KySKuS_checker.conf
chown root:root /etc/KySKuS_checker.conf
systemctl daemon-reload

%postun
if [ $1 -eq 0 ]; then
    systemctl --no-reload disable check.service >/dev/null 2>&1 || :
fi
