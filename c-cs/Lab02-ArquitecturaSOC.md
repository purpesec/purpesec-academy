# Laboratorio CyberSOC: Wazuh + Suricata + DVWA

Guía rápida de implementación para Ubuntu Server 22.04 LTS.

> Uso exclusivo en un entorno de laboratorio aislado. DVWA no debe publicarse en Internet.

## Arquitectura

| Equipo | Dirección | Componentes |
|---|---:|---|
| VM 1 – CyberSOC | `192.168.56.10` | Wazuh Manager, Indexer y Dashboard |
| VM 2 – Cyberrange | `192.168.56.20` | Wazuh Agent, Suricata, DVWA y atacante |
| DVWA | `172.30.0.10` | Aplicación vulnerable |
| Atacante | `172.30.0.20` | Generador de tráfico controlado |

Flujo:

```text
Atacante → DVWA → Suricata → eve.json → Wazuh Agent
                                                ↓
Dashboard ← Indexer ← Wazuh Manager
```

---
## 0. Configuración rápida de IPs

VM1:

```bash
sudo ip addr flush dev ens33 && sudo ip addr add 192.168.56.10/24 dev ens33 && sudo ip link set ens33 up
```

VM2:

```bash
sudo ip addr flush dev ens33 && sudo ip addr add 192.168.56.20/24 dev ens33 && sudo ip link set ens33 up
```

Cambia ens33 por el nombre real de tu interfaz si es distinto.


## 1. Verificación de conectividad

### VM 1

```bash
ip -br address
ping -c 4 192.168.56.20
```

### VM 2

```bash
ip -br address
ping -c 4 192.168.56.10
```

---

## 2. Instalación de Docker

Ejecutar en **VM 1 y VM 2**.

```bash
sudo apt update
sudo apt install -y ca-certificates curl
```

```bash
sudo install -m 0755 -d /etc/apt/keyrings
```

```bash
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
  -o /etc/apt/keyrings/docker.asc
```

```bash
sudo chmod a+r /etc/apt/keyrings/docker.asc
```

```bash
sudo tee /etc/apt/sources.list.d/docker.sources >/dev/null <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/docker.asc
EOF
```

```bash
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io \
  docker-buildx-plugin docker-compose-plugin
```

### Verificación

```bash
sudo systemctl status docker --no-pager
sudo docker compose version
```

---

# VM 1 – CyberSOC

## 3. Despliegue de Wazuh

### 3.1 Instalar Git

```bash
sudo apt update
sudo apt install -y git
```

### 3.2 Configurar el requisito de memoria del Indexer

```bash
sudo sysctl -w vm.max_map_count=262144
```

```bash
sudo tee /etc/sysctl.d/99-wazuh.conf >/dev/null <<EOF
vm.max_map_count=262144
EOF
```

### Verificación

```bash
sysctl vm.max_map_count
```

Resultado esperado:

```text
vm.max_map_count = 262144
```

### 3.3 Descargar Wazuh

```bash
cd /opt
sudo git clone https://github.com/wazuh/wazuh-docker.git -b v4.14.7
cd /opt/wazuh-docker/single-node
```

### 3.4 Generar certificados

```bash
sudo docker compose -f generate-indexer-certs.yml run --rm generator
```

### Verificación

```bash
sudo ls config/wazuh_indexer_ssl_certs
```

### 3.5 Levantar Wazuh

```bash
sudo docker compose up -d
```

### Verificación

```bash
sudo docker compose ps
```

Si algún servicio no inicia:

```bash
sudo docker compose logs --tail=100
```

### 3.6 Comprobar el Dashboard

```bash
curl -k -I https://localhost
```

Acceso:

```text
URL:        https://192.168.56.10
Usuario:    admin
Contraseña: SecretPassword
```

---

# VM 2 – Cyberrange

## 4. Instalación del Wazuh Agent

### 4.1 Agregar el repositorio de Wazuh

```bash
sudo apt update
sudo apt install -y gnupg apt-transport-https curl
```

```bash
curl -s https://packages.wazuh.com/key/GPG-KEY-WAZUH \
  | sudo gpg --no-default-keyring \
  --keyring gnupg-ring:/usr/share/keyrings/wazuh.gpg --import
```

```bash
sudo chmod 644 /usr/share/keyrings/wazuh.gpg
```

```bash
echo "deb [signed-by=/usr/share/keyrings/wazuh.gpg] https://packages.wazuh.com/4.x/apt/ stable main" \
  | sudo tee /etc/apt/sources.list.d/wazuh.list
```

```bash
sudo apt update
```

### 4.2 Instalar el agente

```bash
sudo env \
  WAZUH_MANAGER="192.168.56.10" \
  WAZUH_REGISTRATION_SERVER="192.168.56.10" \
  WAZUH_AGENT_NAME="cyberrange-suricata" \
  apt-get install -y wazuh-agent
```

### 4.3 Iniciar el agente

```bash
sudo systemctl daemon-reload
sudo systemctl enable --now wazuh-agent
```

### Verificación

```bash
sudo systemctl status wazuh-agent --no-pager
```

```bash
sudo grep -E "Connected to|Unable to connect" \
  /var/ossec/logs/ossec.log | tail
```

Resultado esperado:

```text
Connected to the server
```

### 4.4 Verificar el agente desde VM 1

Ejecutar en **VM 1**:

```bash
cd /opt/wazuh-docker/single-node
```

```bash
sudo docker compose exec wazuh.manager \
  /var/ossec/bin/agent_control -lc
```

Resultado esperado:

```text
cyberrange-suricata    Active
```

---

## 5. Despliegue de DVWA y atacante

Ejecutar en **VM 2**.

### 5.1 Crear el proyecto

```bash
sudo mkdir -p /opt/cybersoc-lab
cd /opt/cybersoc-lab
```

```bash
sudo nano compose.yml
```

Contenido:

```yaml
services:
  dvwa:
    image: vulnerables/web-dvwa:latest
    container_name: cybersoc-dvwa
    restart: unless-stopped
    networks:
      lab:
        ipv4_address: 172.30.0.10
    ports:
      - "127.0.0.1:8080:80"

  attacker:
    image: curlimages/curl:latest
    container_name: cybersoc-attacker
    command: ["sleep", "infinity"]
    restart: unless-stopped
    networks:
      lab:
        ipv4_address: 172.30.0.20
    depends_on:
      - dvwa

networks:
  lab:
    name: cybersoc_lab
    driver: bridge
    driver_opts:
      com.docker.network.bridge.name: br-cybersoc
    ipam:
      config:
        - subnet: 172.30.0.0/24
```

### 5.2 Validar y levantar

```bash
sudo docker compose config
sudo docker compose up -d
```

### Verificación

```bash
sudo docker compose ps
ip link show br-cybersoc
```

### 5.3 Probar DVWA

```bash
sudo docker compose exec attacker \
  curl -I http://dvwa/login.php
```

Resultado esperado:

```text
HTTP/1.1 200 OK
```

---

## 6. Instalación de Suricata

### 6.1 Instalar Suricata

```bash
sudo apt update
sudo apt install -y software-properties-common
sudo add-apt-repository -y ppa:oisf/suricata-stable
```

```bash
sudo apt update
sudo apt install -y suricata jq
```

### Verificación

```bash
suricata --build-info
```

### 6.2 Actualizar las reglas

```bash
sudo suricata-update
```

### Verificación

```bash
sudo ls -lh /var/lib/suricata/rules/suricata.rules
```

---

## 7. Configuración de Suricata

Abrir el archivo principal:

```bash
sudo nano /etc/suricata/suricata.yaml
```

### 7.1 Configurar las variables de red

```yaml
HOME_NET: "[172.30.0.0/24]"
EXTERNAL_NET: "any"
```

### 7.2 Configurar la interfaz de captura

Localizar `af-packet` y configurar el primer bloque:

```yaml
af-packet:
  - interface: br-cybersoc
```

### 7.3 Verificar la salida EVE JSON

Modificar la sección existente, sin duplicarla:

```yaml
- eve-log:
    enabled: yes
    filetype: regular
    filename: eve.json
```

---

## 8. Regla local de Suricata

### 8.1 Crear el archivo

```bash
sudo mkdir -p /etc/suricata/rules
sudo nano /etc/suricata/rules/local.rules
```

Agregar en una sola línea:

```suricata
alert http any any -> $HOME_NET any (msg:"CYBERSOC - Acceso HTTP a DVWA"; flow:established,to_server; http.uri; content:"/login.php"; nocase; sid:1000001; rev:1;)
```

### 8.2 Cargar la regla

Abrir:

```bash
sudo nano /etc/suricata/suricata.yaml
```

Configurar la sección:

```yaml
rule-files:
  - suricata.rules
  - /etc/suricata/rules/local.rules
```

### 8.3 Validar la configuración

```bash
sudo suricata -T \
  -c /etc/suricata/suricata.yaml \
  -i br-cybersoc
```

Resultado esperado:

```text
Configuration provided was successfully loaded
```

---

## 9. Configuración del servicio Suricata

Abrir:

```bash
sudo nano /etc/default/suricata
```

Configurar:

```text
RUN=yes
IFACE=br-cybersoc
```

Iniciar el servicio:

```bash
sudo systemctl enable --now suricata
sudo systemctl restart suricata
```

### Verificación

```bash
sudo systemctl status suricata --no-pager
```

```bash
sudo tail -n 30 /var/log/suricata/suricata.log
```

---

## 10. Prueba local de Suricata

### 10.1 Generar tráfico

```bash
cd /opt/cybersoc-lab
```

```bash
sudo docker compose exec attacker \
  curl -s http://dvwa/login.php >/dev/null
```

### 10.2 Buscar la alerta

```bash
sudo jq -c \
  'select(.event_type=="alert" and .alert.signature_id==1000001)' \
  /var/log/suricata/eve.json | tail
```

Datos esperados:

```text
src_ip:       172.30.0.20
dest_ip:      172.30.0.10
signature_id: 1000001
signature:    CYBERSOC - Acceso HTTP a DVWA
```

---

## 11. Integración Suricata–Wazuh

Ejecutar en **VM 2**.

### 11.1 Configurar la recolección de EVE JSON

```bash
sudo nano /var/ossec/etc/ossec.conf
```

Agregar antes del último `</ossec_config>`:

```xml
  <localfile>
    <log_format>json</log_format>
    <location>/var/log/suricata/eve.json</location>
  </localfile>
```

### 11.2 Validar la configuración

```bash
sudo /var/ossec/bin/wazuh-agentd -t
```

### 11.3 Reiniciar el agente

```bash
sudo systemctl restart wazuh-agent
```

### Verificación

```bash
sudo systemctl status wazuh-agent --no-pager
```

---

## 12. Prueba final

### 12.1 Generar cinco eventos desde VM 2

```bash
cd /opt/cybersoc-lab
```

```bash
for i in 1 2 3 4 5; do
  sudo docker compose exec -T attacker \
    curl -s "http://dvwa/login.php?prueba=$i" >/dev/null
done
```

### 12.2 Verificar los eventos en Suricata

```bash
sudo jq -c \
  'select(.event_type=="alert" and .alert.signature_id==1000001)' \
  /var/log/suricata/eve.json | tail -5
```

### 12.3 Verificar los eventos en Wazuh Manager

Ejecutar en **VM 1**:

```bash
cd /opt/wazuh-docker/single-node
```

```bash
sudo docker compose exec wazuh.manager sh -c \
  "grep 'CYBERSOC - Acceso HTTP a DVWA' /var/ossec/logs/alerts/alerts.json | tail"
```

### 12.4 Verificar en Wazuh Dashboard

Acceder a:

```text
https://192.168.56.10
```

Ruta:

```text
Threat intelligence → Threat Hunting
```

Consultas:

```text
rule.groups:suricata
```

```text
data.alert.signature_id:1000001
```

---

## 13. Validación final

```text
[ ] VM 1 y VM 2 tienen conectividad
[ ] Wazuh Manager está levantado
[ ] Wazuh Indexer está levantado
[ ] Wazuh Dashboard responde por HTTPS
[ ] El agente cyberrange-suricata está Active
[ ] DVWA responde desde el atacante
[ ] Existe la interfaz br-cybersoc
[ ] Suricata está active (running)
[ ] eve.json contiene el SID 1000001
[ ] Wazuh Manager recibe la alerta
[ ] La alerta aparece en Threat Hunting
```

---

## Referencias

- [Wazuh: despliegue con Docker](https://documentation.wazuh.com/current/deployment-options/docker/wazuh-container.html)
- [Wazuh: integración con Suricata](https://documentation.wazuh.com/current/proof-of-concept-guide/integrate-network-ids-suricata.html)
- [Suricata Quickstart](https://docs.suricata.io/en/latest/quickstart.html)
- [Docker Engine para Ubuntu](https://docs.docker.com/engine/install/ubuntu/)
