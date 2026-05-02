```markdown
# ☕ CafetínSENA — Base de Datos en Docker

Proyecto de base de datos relacional para la gestión de una cafetería en el Sena,
desarrollado como actividad opcional del trimestre. Implementado con PostgreSQL 17
y administrado mediante pgAdmin 4, todo orquestado con Docker Compose.

---

## 📁 Estructura del proyecto

```
03-optional-activity/
├── docker-compose.yml
├── ddl_CafetinSena_db_actaulizada.sql
├── dml_CafetinSena_db_actaulizada.sql
├── Diagrama ER_CafetinSena.pdf
├── Diagrama Flujo de trabajo.pdf
└── Diagrama bpmn_registro_usuarios_cafetinsena.pdf
```

---

## 🗃️ Módulos de la base de datos

La base de datos `coffee_shop` está compuesta por **27 tablas** organizadas en 6 módulos:

| Módulo | Tablas principales |
|---|---|
| **Status global** | `status` |
| **Parámetros** | `type_document`, `academic_program`, `study_group`, `person`, `file` |
| **Seguridad** | `users`, `role`, `module`, `view`, `user_role`, `role_module`, `module_view` |
| **Inventario** | `category`, `supplier`, `product`, `inventory_movement`, `memory_game_item` |
| **Ventas** | `customer_type`, `customer`, `order_status`, `orders`, `order_item`, `method_payment` |
| **Facturación** | `invoice`, `invoice_item`, `payment` |

---

## 🐳 Servicios Docker

El archivo `docker-compose.yml` define dos servicios:

### `db` — Base de datos
- **Imagen:** `postgres:17`
- **Puerto:** `5434:5432`
- **Inicialización automática:** al levantar el contenedor, PostgreSQL ejecuta
  automáticamente los archivos `.sql` montados en `docker-entrypoint-initdb.d/`,
  creando todas las tablas e insertando los datos de prueba sin intervención manual.
- **Persistencia:** volumen `postgres_data` para que los datos no se pierdan
  al detener el contenedor.

### `pgadmin` — Administrador visual
- **Imagen:** `dpage/pgadmin4`
- **Puerto:** `8080:80`
- **Acceso:** `http://localhost:8080`

---

## 🚀 Cómo levantar el proyecto

### Requisitos previos
- Tener instalado [Docker Desktop](https://www.docker.com/products/docker-desktop/)
- Tener acceso a una terminal (CMD, PowerShell o Git Bash)

### Pasos

**1. Clonar o descargar el proyecto y ubicarse en la carpeta:**
```bash
cd 03-optional-activity
```

**2. Levantar los contenedores:**
```bash
docker compose up -d
```

**3. Verificar que los contenedores estén corriendo:**
```bash
docker compose ps
```
Deberías ver `coffee_shop_db` y `coffee_shop_admin` con estado `running`.

**4. Abrir pgAdmin en el navegador:**
```
http://localhost:8080
```

**5. Registrar el servidor dentro de pgAdmin:**

Clic derecho en *Servers → Register → Server* y completar:

| Campo | Valor |
|---|---|
| Host | `db` |
| Port | `5432` |
| Database | `coffee_shop` |

**6. Para detener los contenedores:**
```bash
docker compose down
```

**7. Para detener y eliminar también los datos:**
```bash
docker compose down -v
```

---

## 🔧 Decisiones técnicas

- Se usó **UUID** como tipo de dato para todas las claves primarias, garantizando
  identificadores únicos globales sin depender de secuencias numéricas.
- Todas las tablas incluyen campos de auditoría: `created_at`, `updated_at`,
  `deleted_at`, `created_by`, `updated_by`, `deleted_by`, implementando
  **borrado lógico** en lugar de eliminación física.
- La tabla `status` actúa como **catálogo global de estados**, referenciada por
  todas las demás tablas mediante `status_id`.
- Los archivos SQL se montan en `docker-entrypoint-initdb.d/` para que
  PostgreSQL los ejecute automáticamente en el primer arranque del contenedor.

---

## 📊 Diagramas incluidos

- **Diagrama ER** — Modelo entidad-relación con las 27 tablas y sus relaciones.
- **Diagrama BPMN** — Flujo del proceso de registro de usuarios en el sistema.
- **Diagrama de flujo de trabajo** — Descripción del flujo operativo general.

---

## 🛠️ Tecnologías utilizadas

- PostgreSQL 17
- pgAdmin 4
- Docker & Docker Compose
- SQL (DDL + DML)
```