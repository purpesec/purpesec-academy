# Rutas de ciberseguridad

Repositorio de formación en ciberseguridad con cinco cursos organizados por sesiones, contenido práctico, guías paso a paso y laboratorios diseñados para ejecutarse en entornos controlados.

> [!CAUTION]
> Los laboratorios incluyen máquinas y aplicaciones vulnerables de forma intencional. Utiliza solo entornos aislados y sistemas propios o para los que tengas autorización expresa.

## Catálogo

| # | Ruta | Enfoque | Contenido disponible | Estado |
|---|---|---|---:|---|
| 1 | [CyberSOC](./cybersoc/) | SIEM, IDS, monitoreo y gestión de alertas | 1 sesión | En desarrollo |
| 2 | [Ethical Hacking](./ethical-hacking/) | Reconocimiento y enumeración de infraestructura | 1 sesión | En desarrollo |
| 3 | [Malware Analysis](./malware-analysis/) | Análisis estático de muestras simuladas | 1 sesión | En desarrollo |
| 4 | [Pentesting Web](./pentesting-web/) | Fundamentos web, SQL y aplicaciones vulnerables | 1 sesión | En desarrollo |
| 5 | [Privilege Escalation](./privilege-escalation/) | Escalada de privilegios en Linux y Windows | 0 sesiones | Planificado |

`Disponible` indica que la sesión tiene material y laboratorio. `En desarrollo` indica que la ruta se publicará de forma progresiva. `Planificado` indica que todavía no hay sesiones publicadas.

## Cómo estudiar

1. Prepara el entorno con la [guía de configuración](./setup/).
2. Elige una ruta y revisa sus prerrequisitos.
3. Lee la introducción de la sesión y completa su laboratorio.
4. Conserva las evidencias solicitadas: comandos, capturas, resultados y conclusiones.
5. Verifica los criterios de finalización antes de continuar.

## Formato de una sesión

```text
curso/
|-- README.md                 # Índice y progreso de la ruta
`-- NN-tema/
    |-- README.md             # Objetivos, conceptos y criterios de éxito
    `-- lab/
        |-- README.md         # Guía práctica
        `-- archivos-de-apoyo
```

La numeración conserva el orden de las sesiones impartidas. Por eso algunas rutas empiezan en `02` o `03`; las sesiones anteriores se incorporarán cuando su material esté listo para publicarse.

## Estructura del repositorio

```text
.
|-- setup/                    # Preparación y aislamiento del laboratorio
|-- cybersoc/                 # Ruta CyberSOC
|-- ethical-hacking/          # Ruta Ethical Hacking
|-- malware-analysis/         # Ruta Malware Analysis
|-- pentesting-web/           # Ruta Pentesting Web
|-- privilege-escalation/     # Ruta Privilege Escalation
|-- images/                   # Diagramas compartidos
`-- resources/                # Material complementario
```

## Uso responsable

- No pruebes técnicas contra sistemas de terceros sin autorización.
- No conectes máquinas vulnerables directamente a Internet.
- No subas credenciales, capturas con datos personales, malware real ni archivos generados por las VMs.
- La presencia de código vulnerable en un laboratorio es intencional y se documenta como tal.

## Contribuir

Consulta [CONTRIBUTING.md](./CONTRIBUTING.md) para publicar una sesión o mejorar un laboratorio. Para reportes de seguridad del repositorio, consulta [SECURITY.md](./SECURITY.md).
