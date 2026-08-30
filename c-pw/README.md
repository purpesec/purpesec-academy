## 1. Preparar el entorno

Instalar el gestor, el servidor web y el módulo PHP-MySQL:

```bash
apt install mariadb-server apache2 php php-mysql
```

Levantar los servicios:

```bash
service mysql start     # abre el puerto 3306
service apache2 start   # abre el puerto 80
```

Si no empieza mysql  

```bash
systemctl start mariadb
systemctl start apache2
```
## 2. Explorar el servidor (conceptos de SQL)

Conectarse como root (en el lab local no pide contraseña):

```bash
mysql
```

Dentro del cliente:

```sql
SHOW DATABASES;         -- information_schema, mysql, performance_schema
USE mysql;
SHOW TABLES;
DESCRIBE user;          -- columnas: Host, User, Password, ...

SELECT user, password FROM user;
SELECT * FROM user WHERE user = 'root';
```

## 3. Crear la base del laboratorio

Ejecutar `setup.sql` o copiar sus sentencias:

```sql
-- Entorno de práctica SQL — Sesión 2
-- Ejecutar dentro del cliente mysql como root (sin contraseña en el entorno local).

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

```

Luego volcamos la base de datos creada en mysql 

```bash
mysql < setup.sql
```

Resultado: base `tienda`, tabla `users(id, username, password)` con:

| id  | username | password |
| --- | -------- | -------- |
| 1   | admin    | p@ssw0rd |
| 2   | john     | john123  |
| 3   | jane     | jane456  |

## 4. Desplegar la aplicación vulnerable (searchusers.php)

Copiar el script a la raíz web ( /var/www/html )

Entonces quedaria el archivo en /var/www/html/searchusers.php

```php
<?php

$server = "localhost";
$username = "appuser";
$password = "appuser123";
$database = "tienda";

$conn = new mysqli($server, $username, $password, $database);

$id = isset($_GET['id']) ? $_GET['id'] : '';

$data = mysqli_query(
    $conn,
    "SELECT username FROM users WHERE id = '$id'"
) or die(mysqli_error($conn));

$response = mysqli_fetch_array($data);

if ($response) {
    echo $response['username'];
}

?>
```
