#!/bin/bash
set -eu

mariadb --protocol=socket -uroot -p"${MARIADB_ROOT_PASSWORD}" <<-EOSQL
CREATE USER IF NOT EXISTS '${DB_USER}'@'%' IDENTIFIED BY '${DB_PASSWORD}';
GRANT SELECT, SHOW VIEW ON oficina_agua.* TO '${DB_USER}'@'%';
FLUSH PRIVILEGES;
EOSQL
