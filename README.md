# KySKuS-checker

Служба мониторинга системных файлов для Fedora.

- Отслеживает изменения в `/etc/passwd`, `/etc/group`, `/etc/sudoers`(опционально)
- Запись в журнал 
- Адаптивно(есть возмодност кастомизации)
- Показывает изменения

## Установка

1. Соберите RPM:
   ```bash
   sudo dnf install -y git rpm-build dnf-plugins-core
   git clone https://github.com/KySKuS/KySKuS_checker.git
 ### распакуйте архив 
   cd KySKuS_checker
   rpmbuild \
   --buildroot "$(pwd)/root" \
   --define "_topdir $(pwd)" \
   -bb KySKuS_checker.spec
  # После установки
     
     sudo dnf install -y RPMS/noarch/KySKuS_checker-*.rpm
     sudo systemctl enable --now check
     kyskus-checker get all
# Настройка и управление


## Удаляем всё старое 
### Удалить пакет
sudo dnf remove -y KySKuS_checker
### Удалить остаточные файлы (опционально)
sudo rm -rf /var/lib/check

### Доступные параметры
| Атрибут | Для чего используется |
| ------------- | ------------- |
| interval  | Интервал проверки (в секундах) |
| files  | Список файлов для мониторинга   |
| auto_start  |  Включить автозапуск при загрузке  |

### Примеры
```bash
   kyskus-checker get all  
   sudo kyskus-checker set interval 30  
   sudo kyskus-checker set files /etc/passwd,/etc/hosts  
   sudo kyskus-checker set auto_start true   # включить автозапуск  
   sudo kyskus-checker set auto_start false  # выключить автозапуск
   systemctl status check #проверить статус службы
   systemctl restart check #перезапустить вручную
