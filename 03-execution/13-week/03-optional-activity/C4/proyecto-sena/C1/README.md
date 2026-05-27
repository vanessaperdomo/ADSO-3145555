# C4 Model — PRJ-EDU-HORARIOS: Sistema de Gestión de Horarios Académicos

> Documento vivo. Última actualización: 2026-05-20
> Autor: Jesús Ariel González Bonilla
> Proyecto: PRJ-EDU-HORARIOS

---

## Nivel 1 — Context Diagram (Vista de alto nivel del sistema)

### ¿Qué muestra este nivel?
El sistema completo visto desde afuera. Responde a: **¿Quién usa el sistema y con qué sistemas externos se relaciona?**

---

### Diagrama (Mermaid)

````mermaid
C4Context
  title Sistema de Gestión de Horarios Académicos — Contexto

  Person(coord, "Coordinador Académico", "Programa fichas, asigna instructores y ambientes sin cruces.")
  Person(instructor, "Instructor", "Consulta su horario y carga horaria semanal. Registra observaciones.")
  Person(adminAmb, "Administrador de Ambientes", "Gestiona el inventario de salones, laboratorios y recursos.")

  System(horarios, "PRJ-EDU-HORARIOS", "Plataforma web centralizada que valida y gestiona la programación académica en tiempo real, previniendo conflictos de asignación.")

  System_Ext(siga, "SIGA / ERP Institucional", "Sistema externo de matrículas, nómina y datos maestros institucionales. (Integración fuera del MVP)")
  System_Ext(email, "Servidor de Correo", "Envío de notificaciones básicas. (Fuera del MVP v1.0)")

  Rel(coord, horarios, "Crea y gestiona programación académica", "HTTPS / Web UI")
  Rel(instructor, horarios, "Consulta horario y registra observaciones", "HTTPS / Web UI")
  Rel(adminAmb, horarios, "Mantiene catálogo de ambientes", "HTTPS / Web UI")

  Rel(horarios, siga, "Futura integración de datos maestros", "REST API (fase 2)")
  Rel(horarios, email, "Futuras notificaciones de cambio", "SMTP (fase 2)")
````

---

### Actores del sistema

| Actor | Rol | Job-to-be-done principal |
|---|---|---|
| Coordinador Académico | Usuario principal / power user | Programar carga académica sin generar cruces |
| Instructor | Usuario de consulta + retroalimentación | Ver su horario y reportar novedades |
| Administrador de Ambientes | Usuario de catálogo | Mantener datos de salones y laboratorios actualizados |

---

### Sistemas externos

| Sistema | Tipo | Estado en MVP |
|---|---|---|
| SIGA / ERP Institucional | Sistema externo de datos maestros | **Fuera de alcance — Fase 2** |
| Servidor de Correo | Canal de notificaciones | **Fuera de alcance — Fase 2** |

---

### Notas de decisión de este nivel

- El sistema es **web-responsive**; no existe app móvil nativa en el MVP.
- La integración con el ERP institucional es un **riesgo conocido** diferido explícitamente.
- La triple restricción de validación (**Instructor + Ambiente + Ficha** en la misma franja horaria) es el núcleo del valor del sistema.

---

> Siguiente nivel: [`level-2-containers.md`](./level-2-containers.md)