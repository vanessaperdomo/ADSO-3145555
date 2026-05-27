# C4 Model — Nivel 2: Containers Diagram

> PRJ-EDU-HORARIOS | Última actualización: 2026-05-20

---

## ¿Qué muestra este nivel?
Los contenedores técnicos que componen el sistema: microservicios, bases de datos, message broker, caché y el API Gateway. Responde a: **¿Cómo está construido técnicamente el sistema?**

---

## Diagrama (Mermaid)

````mermaid
C4Container
  title PRJ-EDU-HORARIOS — Containers Diagram

  Person(coord, "Coordinador Académico")
  Person(instructor, "Instructor")
  Person(adminAmb, "Administrador de Ambientes")

  System_Boundary(horarios, "PRJ-EDU-HORARIOS") {

    Container(webapp, "Web App (SPA)", "React / TypeScript", "Interfaz de usuario web. Programación de horarios, consultas y reportes.")

    Container(gateway, "API Gateway", "Kong / Nginx", "Punto único de entrada. Enrutamiento, autenticación JWT y rate limiting.")

    Container(svc_horarios, "svc-horarios", "Node.js / NestJS", "Motor de horarios. Valida triple restricción y gestiona franjas. Core del negocio.")
    Container(svc_catalogos, "svc-catalogos", "Node.js / NestJS", "CRUD de Ambientes, Fichas e Instructores.")
    Container(svc_reportes, "Node.js / NestJS", "svc-reportes", "Generación de reportes de carga horaria y ocupación de ambientes.")
    Container(svc_observaciones, "svc-observaciones", "Node.js / NestJS", "Registro y seguimiento de observaciones vinculadas a actores.")
    Container(svc_auth, "svc-auth", "Node.js / NestJS", "Autenticación y emisión de tokens JWT.")

    ContainerDb(db_horarios, "DB Horarios", "PostgreSQL", "Franjas horarias, asignaciones validadas.")
    ContainerDb(db_catalogos, "DB Catálogos", "PostgreSQL", "Ambientes, Fichas, Instructores.")
    ContainerDb(db_observaciones, "DB Observaciones", "PostgreSQL", "Observaciones y su estado.")
    ContainerDb(cache, "Cache", "Redis", "Disponibilidad en tiempo real, sesiones y resultados frecuentes.")
    Container(broker, "Message Broker", "RabbitMQ", "Comunicación asíncrona entre servicios. Eventos de cambio de horario.")
  }

  Rel(coord, webapp, "Usa", "HTTPS")
  Rel(instructor, webapp, "Usa", "HTTPS")
  Rel(adminAmb, webapp, "Usa", "HTTPS")

  Rel(webapp, gateway, "Consume API", "HTTPS / REST")

  Rel(gateway, svc_auth, "Valida token / login", "REST")
  Rel(gateway, svc_horarios, "Enruta peticiones de horarios", "REST")
  Rel(gateway, svc_catalogos, "Enruta peticiones de catálogos", "REST")
  Rel(gateway, svc_reportes, "Enruta peticiones de reportes", "REST")
  Rel(gateway, svc_observaciones, "Enruta peticiones de observaciones", "REST")

  Rel(svc_horarios, db_horarios, "Lee / Escribe", "TCP")
  Rel(svc_horarios, cache, "Consulta disponibilidad en tiempo real", "TCP")
  Rel(svc_horarios, broker, "Publica evento HorarioCreado / Modificado", "AMQP")

  Rel(svc_catalogos, db_catalogos, "Lee / Escribe", "TCP")
  Rel(svc_catalogos, broker, "Publica evento CatálogoActualizado", "AMQP")

  Rel(svc_observaciones, db_observaciones, "Lee / Escribe", "TCP")
  Rel(svc_observaciones, broker, "Suscribe a eventos de horario", "AMQP")

  Rel(svc_reportes, db_horarios, "Lee (read-only)", "TCP")
  Rel(svc_reportes, db_catalogos, "Lee (read-only)", "TCP")
  Rel(svc_reportes, cache, "Cachea reportes frecuentes", "TCP")
````

---

## Inventario de contenedores

| Contenedor | Tecnología | Responsabilidad principal |
|---|---|---|
| Web App (SPA) | React + TypeScript | UI responsive para todos los actores |
| API Gateway | Kong / Nginx | Enrutamiento, JWT validation, rate limiting |
| svc-auth | NestJS + PostgreSQL | Autenticación, emisión y validación de JWT |
| svc-horarios | NestJS + PostgreSQL | **Core**: motor de validación de triple restricción |
| svc-catalogos | NestJS + PostgreSQL | CRUD maestros: Ambientes, Fichas, Instructores |
| svc-reportes | NestJS | Reportes de carga horaria y ocupación |
| svc-observaciones | NestJS + PostgreSQL | Registro y seguimiento de observaciones |
| Redis | Redis | Caché de disponibilidad en tiempo real y sesiones |
| RabbitMQ | AMQP | Eventos asincrónicos entre servicios |
| PostgreSQL (x3) | PostgreSQL 15 | Persistencia por dominio (BD por servicio) |

---

## Decisiones técnicas clave de este nivel

| Decisión | Justificación |
|---|---|
| **Una BD por servicio** | Aislamiento de datos por dominio. Evita acoplamiento de esquemas entre servicios. |
| **Redis para disponibilidad** | La consulta de ambientes libres en tiempo real requiere latencia mínima. No puede ir directo a PostgreSQL en cada keystroke del formulario. |
| **RabbitMQ sobre Kafka** | Volumen de mensajes bajo-medio en el MVP. RabbitMQ tiene menor overhead operacional para este tamaño. Migración a Kafka es posible si el volumen escala. |
| **API Gateway único** | Simplifica autenticación centralizada y evita que cada servicio implemente su propio middleware de seguridad. |
| **NestJS para todos los servicios** | Consistencia de stack. Reduce la curva de onboarding del equipo entre servicios. |

---

> Anterior: [`level-1-context.md`](./level-1-context.md)
> Siguiente: [`level-3-components.md`](./level-3-components.md)