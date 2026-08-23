-- 1. Crear la base de datos de práctica
CREATE DATABASE IF NOT EXISTS tienda;

-- 2. Usarla
USE tienda;

-- 3. Crear la tabla de usuarios
CREATE TABLE IF NOT EXISTS users (
  id       INT PRIMARY KEY,
  username VARCHAR(32),
  password VARCHAR(32)
);

-- 4. Insertar los registros
INSERT INTO users (id, username, password) VALUES
  (1, 'admin', 'p@ssw0rd'),
  (2, 'john', 'john123'),
  (3, 'jane', 'jane456')
ON DUPLICATE KEY UPDATE
  username = VALUES(username),
  password = VALUES(password);

-- 5. Crear el usuario que usará la aplicación (mínimos privilegios, solo esta base)
CREATE USER IF NOT EXISTS 'appuser'@'localhost' IDENTIFIED BY 'appuser123';

-- 6. Otorgar privilegios sobre la base tienda
GRANT ALL PRIVILEGES ON tienda.* TO 'appuser'@'localhost';

-- 7. Aplicar los cambios de privilegios
FLUSH PRIVILEGES;