CREATE USER IF NOT EXISTS 'consulta_ro'@'%' IDENTIFIED BY 'consulta_ro_dev_only';
GRANT SELECT ON oficina_agua.* TO 'consulta_ro'@'%';
FLUSH PRIVILEGES;
