cd §MOODLE_HTDOCS
   $ sudo -u apache /usr/bin/php admin/cli/maintenance.php --enable
   $ git pull
   $ sudo -u apache /usr/bin/php admin/cli/upgrade.php
   $ sudo -u apache /usr/bin/php admin/cli/maintenance.php --disable
