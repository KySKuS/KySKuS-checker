# KySKuS-checker

Служба мониторинга системных файлов для Fedora.

- Отслеживает изменения в `/etc/passwd`, `/etc/group`, `/etc/sudoers`(опционально)
- Запись в журнал 
- Адаптивно(есть возмодност кастомизации)
- Показывает изменения

## Установка

1. Соберите RPM:
   ```bash
   sudo dnf install -y rpm-build rpmdevtools
   git clone https://github.com/KySKuS/KySKuS_checker.git
   cd KySKuS_checker
   mkdir -p ~/rpmbuild/{BUILD,RPMS,SOURCES,SPECS,SRPMS}
   cp check.sh kyskus-checker check.service ~/rpmbuild/SOURCES/
   cp KySKuS_checker.spec ~/rpmbuild/SPECS/
   cp KySKuS_checker.conf.example ~/rpmbuild/SOURCES/KySKuS_checker.conf
   rpmbuild -bb ~/rpmbuild/SPECS/KySKuS_checker.spec
## Настройка и управление
### Доступные параметры

| ------------- | ------------- |
| interval  | Интервал проверки (в секундах) |
| files  | Список файлов для мониторинга   |
| auto_start  |  Включить автозапуск при загрузке  |
