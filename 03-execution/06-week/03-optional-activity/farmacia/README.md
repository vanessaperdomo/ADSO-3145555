# 💊 Farmacia DB — Liquibase Migration Project

Sistema de versionado de base de datos para una Farmacia usando **Liquibase 4.27** y **PostgreSQL 16**.

---

## 📂 Estructura del Proyecto

```
farmacia/
│
├── db.changelog-master.xml          # ← Punto de entrada principal
│
├── changelogs/
│   ├── ddl/                         # Creación de tablas (estructura)
│   │   ├── 001-create-categoria.xml
│   │   ├── 002-create-proveedor.xml
│   │   ├── 003-create-medicamento.xml
│   │   ├── 004-create-cliente.xml
│   │   ├── 005-create-venta.xml
│   │   └── 006-create-detalle-venta.xml
│   │
│   ├── indexes/                     # Índices de rendimiento
│   │   └── 001-indexes.xml
│   │
│   └── dml/                         # Datos iniciales (seed)
│       ├── 001-seed-categorias.xml
│       ├── 002-seed-proveedores.xml
│       ├── 003-seed-medicamentos.xml
│       ├── 004-seed-clientes.xml
│       ├── 005-seed-ventas.xml
│       └── 006-seed-detalle-ventas.xml
│
├── sql_scripts/                     # Consultas analíticas y de auditoría
│   ├── auditoria_liquibase.sql
│   ├── estadisticas_farmacia.sql
│   └── reporte_maestro.sql
│
├── lib/
│   └── postgresql-42.7.10.jar       # Driver JDBC (copiar del proyecto zoo)
│
├── docker-compose.yml
├── .env.example                     # Plantilla de variables de entorno
└── .gitignore
```

---

## 🚀 Inicio Rápido

### 1. Configurar variables de entorno

```bash
cp .env.example .env
# Editar .env con tus credenciales reales si lo deseas
```

### 2. Copiar el driver JDBC

```bash
# Copia el jar desde el proyecto zoo (o descárgalo de Maven Central)
cp ../zoo/lib/postgresql-42.7.10.jar ./lib/
```

### 3. Levantar con Docker Compose

```bash
docker compose up
```

Liquibase esperará automáticamente a que PostgreSQL esté listo (`healthcheck`) antes de ejecutar las migraciones.

### 4. Verificar migraciones aplicadas

```bash
docker compose run --rm liquibase \
  --changelog-file=db.changelog-master.xml \
  --url=jdbc:postgresql://db:5432/farmacia_db \
  --username=admin_farmacia \
  --password=changeme_en_produccion \
  status
```

---

## 🔄 Comandos Útiles de Liquibase

| Acción | Comando |
|---|---|
| Aplicar migraciones | `update` |
| Ver estado pendiente | `status` |
| Revertir último changeset | `rollbackCount 1` |
| Revertir hasta una tag | `rollback <tag>` |
| Generar SQL sin ejecutar | `updateSQL` |
| Validar changelog | `validate` |

---

## 🗄️ Modelo de Datos

```
categoria ──────────────────────────┐
                                    │
proveedor ──────────────────────── medicamento
                                    │
cliente ──────────── venta ──── detalle_venta
```

### Tablas

| Tabla | Descripción |
|---|---|
| `categoria` | Clasificación terapéutica (Analgésico, Antibiótico, etc.) |
| `proveedor` | Laboratorios y distribuidores que surten la farmacia |
| `medicamento` | Catálogo de productos con stock e inventario |
| `cliente` | Clientes registrados con documento de identidad |
| `venta` | Cabecera de cada transacción de venta |
| `detalle_venta` | Líneas de ítems de cada venta |

---

## ✅ Buenas Prácticas Aplicadas

- **IDs semánticos** en cada changeset (`ddl-001-create-categoria`)
- **`<rollback>`** explícito en todos los changesets
- **`<comment>`** descriptivo en cada changeset
- **Constraints CHECK** para valores de dominio (forma farmacéutica, método de pago, tipo documento, etc.)
- **Índices** separados del DDL para control granular
- **Datos seed separados del DDL** (carpetas `dml/` vs `ddl/`)
- **Versión fija** de imagen Docker (`postgres:16-alpine`, `liquibase:4.27`)
- **`healthcheck`** en Docker Compose para evitar race conditions
- **`.env.example`** para documentar variables sin exponer credenciales
- **`SERIAL`** en lugar de `int autoIncrement` para mejor compatibilidad PostgreSQL
- **`remarks`** en columnas como documentación embebida
- **FK nullable** en `venta.cliente_id` para permitir ventas anónimas

---

## 📊 Scripts SQL incluidos

- `auditoria_liquibase.sql` — historial de migraciones, locks y fallos
- `estadisticas_farmacia.sql` — stock bajo, ventas por día, top medicamentos, vencimientos
- `reporte_maestro.sql` — ficha completa de cada venta con cliente y detalle
