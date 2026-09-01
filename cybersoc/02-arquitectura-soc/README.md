# Sesión 02: Arquitectura SOC

[Inicio](../../README.md) | [CyberSOC](../README.md) | [Laboratorio](./lab/)

| Campo | Valor |
|---|---|
| Estado | Disponible |
| Duración estimada | 4 a 6 horas |
| Nivel | Intermedio |
| Modalidad | Lectura y laboratorio guiado |

## Objetivo

Construir una arquitectura SOC de laboratorio con Wazuh como plataforma SIEM/XDR y Suricata como IDS de red, y verificar el recorrido completo de una alerta generada contra DVWA.

## Resultados de aprendizaje

Al finalizar podrás:

- Identificar las responsabilidades de Wazuh Manager, Indexer, Dashboard y Agent.
- Explicar cómo Suricata transforma tráfico de red en eventos EVE JSON.
- Integrar la salida de Suricata con un agente de Wazuh.
- Generar, localizar y validar una alerta desde el origen hasta el dashboard.

## Fundamentos

Un SOC necesita convertir actividad técnica en señales que puedan investigarse. En este laboratorio, Suricata inspecciona el tráfico del cyberrange y escribe eventos estructurados en `eve.json`. El agente de Wazuh recoge esos eventos y los envía al Manager, donde se procesan antes de almacenarse en el Indexer y visualizarse en el Dashboard.

```text
Atacante -> DVWA -> Suricata -> eve.json -> Wazuh Agent
                                                |
Dashboard <- Indexer <- Wazuh Manager <---------+
```

La prueba no termina cuando una herramienta genera una alerta. La validación correcta demuestra cada etapa del flujo: tráfico, evento local, recepción en el Manager y consulta en el Dashboard.

## Arquitectura

| Equipo | Dirección | Componentes |
|---|---:|---|
| VM 1: CyberSOC | `192.168.56.10` | Wazuh Manager, Indexer y Dashboard |
| VM 2: Cyberrange | `192.168.56.20` | Wazuh Agent, Suricata, DVWA y atacante |

## Laboratorio

Sigue el [laboratorio de Wazuh, Suricata y DVWA](./lab/). Desplegarás los componentes, crearás una regla local y comprobarás el recorrido de la alerta.

## Evidencias

- Estado de los servicios y contenedores.
- Registro EVE JSON con el SID `1000001`.
- Agente activo en Wazuh.
- Alerta visible en Threat Hunting.
- Breve explicación del flujo seguido por el evento.

## Criterio de finalización

La sesión está completa cuando puedes generar una petición controlada a DVWA y encontrar la misma alerta tanto en Suricata como en Wazuh.

[Volver a CyberSOC](../README.md) | [Abrir laboratorio](./lab/) | [Inicio](../../README.md)
