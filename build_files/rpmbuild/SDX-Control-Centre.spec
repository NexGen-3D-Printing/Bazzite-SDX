Name:           sdx-control-centre
Version:        1.0.1
Release:        1%{?dist}
Summary:        SDX Control Centre for Bazzite-DX Surface devices

License:        GPL-3.0
URL:            https://github.com/NexGen-3D-Printing/SDX-Control-Centre
Source0:        sdx-control-centre-1.0.1.tar.gz

BuildArch:      noarch

Requires:       python3 >= 3.10
Requires:       python3-gobject
Requires:       python3-pyqt6
Requires:       polkit
Requires:       systemd

%description
SDX Control Centre is a comprehensive system management application for Bazzite-DX (Surface Development Edition).
It provides controls for display, keyboard, performance, thermals, power, sleep, and system diagnostics.

Built on the shoulders of giants. This project is a fork of Lane "Madmaxx636" Surface Companion
(https://github.com/Madmaxx636/surface-companion). We extend our gratitude to Madmaxx636 for creating and
maintaining the original project, which has enabled this fork to exist.

## Features

- Display & keyboard: Screen brightness, keyboard backlight
- Performance & thermals: Surface power profile, temperatures, fan speed, CPU throttling
- Power & sleep: Sleep mode, lid action, charge limit, battery health
- System diagnostics: Health checks, hands-on tests, support bundles

%prep
%setup -q -n sdx-control-centre-1.0.1

%build
# No build needed - pure Python application

%install
mkdir -p %{buildroot}%{_libdir}/%{name}
cp -r src/surface_companion %{buildroot}%{_libdir}/%{name}/
find %{buildroot}%{_libdir}/%{name} -name __pycache__ -type d -prune -exec rm -rf {} +

mkdir -p %{buildroot}%{_bindir}
cat > %{buildroot}%{_bindir}/sdx-control-centre << 'EOF'
#!/bin/bash
PYTHONPATH=%{_libdir}/%{name} exec python3 -m surface_companion "$@"
EOF
cat > %{buildroot}%{_bindir}/sdx-control-centred << 'EOF'
#!/bin/bash
PYTHONPATH=%{_libdir}/%{name} exec python3 -m surface_companion.daemon.service "$@"
EOF
chmod 755 %{buildroot}%{_bindir}/sdx-control-centre %{buildroot}%{_bindir}/sdx-control-centred

mkdir -p %{buildroot}%{_datadir}/applications
cp data/sdx-control-centre.desktop %{buildroot}%{_datadir}/applications/sdx-control-centre.desktop
cp data/sdx-control-centre-autostart.desktop %{buildroot}%{_datadir}/applications/sdx-control-centre-autostart.desktop
chmod 644 %{buildroot}%{_datadir}/applications/sdx-control-centre*.desktop

mkdir -p %{buildroot}%{_datadir}/icons/hicolor/scalable/apps
cp data/sdx-control-centre.svg %{buildroot}%{_datadir}/icons/hicolor/scalable/apps/sdx-control-centre.svg
chmod 644 %{buildroot}%{_datadir}/icons/hicolor/scalable/apps/*.svg

mkdir -p %{buildroot}%{_datadir}/polkit-1/actions
cp data/org.sdxcontrolcentre.policy %{buildroot}%{_datadir}/polkit-1/actions/org.sdxcontrolcentre.policy
chmod 644 %{buildroot}%{_datadir}/polkit-1/actions/*.policy

mkdir -p %{buildroot}%{_datadir}/dbus-1/system.d
cp data/org.sdxcontrolcentre.Daemon.conf %{buildroot}%{_datadir}/dbus-1/system.d/org.sdxcontrolcentre.Daemon.conf
chmod 644 %{buildroot}%{_datadir}/dbus-1/system.d/*.conf

mkdir -p %{buildroot}%{_datadir}/dbus-1/system-services
cp data/org.sdxcontrolcentre.Daemon.service %{buildroot}%{_datadir}/dbus-1/system-services/org.sdxcontrolcentre.Daemon.service
chmod 644 %{buildroot}%{_datadir}/dbus-1/system-services/*.service

mkdir -p %{buildroot}%{_unitdir}
cp data/sdx-control-centre.service %{buildroot}%{_unitdir}/sdx-control-centre.service
chmod 644 %{buildroot}%{_unitdir}/*.service

%post
%systemd_post sdx-control-centre.service
%{_sbindir}/update-desktop-database %{_datadir}/applications 2>/dev/null || true
%{_sbindir}/gtk-update-icon-cache %{_datadir}/icons/hicolor 2>/dev/null || true

%preun
%systemd_preun sdx-control-centre.service

%postun
%systemd_postun sdx-control-centre.service
%{_sbindir}/update-desktop-database %{_datadir}/applications 2>/dev/null || true
%{_sbindir}/gtk-update-icon-cache %{_datadir}/icons/hicolor 2>/dev/null || true

%files
%{_bindir}/sdx-control-centre
%{_bindir}/sdx-control-centred
%{_libdir}/%{name}/
%{_datadir}/applications/sdx-control-centre.desktop
%{_datadir}/applications/sdx-control-centre-autostart.desktop
%{_datadir}/icons/hicolor/scalable/apps/sdx-control-centre.svg
%{_datadir}/polkit-1/actions/org.sdxcontrolcentre.policy
%{_datadir}/dbus-1/system.d/org.sdxcontrolcentre.Daemon.conf
%{_datadir}/dbus-1/system-services/org.sdxcontrolcentre.Daemon.service
%{_unitdir}/sdx-control-centre.service

%changelog
* Thu Nov 12 2026 NexGen3D - 1.0.1-1
- Rename project/runtime identifiers/assets to SDX Control Centre (sdx-control-centre)
- Align D-Bus/polkit/service/packaging and add legacy compatibility for state and managed fixes
- UI/UX and platform fixes (Bazzite PPD profiles, theming, scroll/touch, frameless window)

* Wed Nov 11 2026 NexGen3D - 0.3.0-1
- Initial package for Bazzite-SDX
- Forked from Madmaxx636's Surface Companion (MIT) and upgraded to GPLv3
- Renamed to SDX Control Centre
