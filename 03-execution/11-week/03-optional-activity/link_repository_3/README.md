# 🎬 Proyecto Cine — Entrega Final

Sistema completo de gestión de cine compuesto por tres repositorios independientes:
base de datos, API backend y frontend web.

---

## 📦 Repositorios

| Capa | Repositorio | Estado CI |
|------|-------------|-----------|
| 🗄️ Base de Datos | [vanessaperdomo/BaseDeDatos_Cine](https://github.com/vanessaperdomo/BaseDeDatos_Cine) | ![CI](https://github.com/vanessaperdomo/BaseDeDatos_Cine/actions/workflows/ci.yml/badge.svg) |
| ⚙️ Backend API | [vanessaperdomo/Backend_API_Cine](https://github.com/vanessaperdomo/Backend_API_Cine) | ![CI](https://github.com/vanessaperdomo/Backend_API_Cine/actions/workflows/ci.yml/badge.svg) |
| 🖥️ Frontend | [vanessaperdomo/Frontend_Cine](https://github.com/vanessaperdomo/Frontend_Cine) | ![CI](https://github.com/vanessaperdomo/Frontend_Cine/actions/workflows/ci.yml/badge.svg) |

---

## 🗄️ 1. Base de Datos

**Repositorio:** https://github.com/vanessaperdomo/BaseDeDatos_Cine

PostgreSQL con Liquibase. Contiene 4 tablas normalizadas hasta 3NF:
`movies`, `clients`, `screening_rooms`, `rentals`.

### Requisitos
- Docker
- Docker Compose

### Ejecución

```bash
# 1. Clonar el repositorio
git clone https://github.com/vanessaperdomo/BaseDeDatos_Cine.git
cd BaseDeDatos_Cine/cinema

# 2. Levantar la base de datos y aplicar migraciones
docker-compose up --build
```

> Liquibase crea el schema, las tablas e inserta los datos automáticamente.

### Conexión

| Parámetro  | Valor           |
|------------|-----------------|
| Host       | `localhost`     |
| Puerto     | `5433`          |
| Base       | `cine_db`       |
| Usuario    | `cine_user`     |
| Contraseña | `cine_password` |

---

## ⚙️ 2. Backend API

**Repositorio:** https://github.com/vanessaperdomo/Backend_API_Cine

API REST construida con Spring Boot 3 + Java 17 + JPA.
Expone endpoints para movies, clients, screening rooms y rentals.

### Requisitos
- Java 17
- Maven
- Docker (opcional)
- Base de datos corriendo (ver paso anterior)

### Ejecución local

```bash
# 1. Clonar el repositorio
git clone https://github.com/vanessaperdomo/Backend_API_Cine.git
cd Backend_API_Cine/cinema

# 2. Compilar y ejecutar
mvn spring-boot:run
```

### Ejecución con Docker

```bash
# Construir imagen
docker build -t cinema-api:latest .

# Ejecutar contenedor
docker run -p 8080:8080 cinema-api:latest
```

### Documentación API

Una vez corriendo, acceder a Swagger UI:

```
http://localhost:8080/swagger-ui.html
```

---

## 🖥️ 3. Frontend

**Repositorio:** https://github.com/vanessaperdomo/Frontend_Cine

Interfaz web en HTML, CSS y JavaScript vanilla.
Consume la API del backend para gestionar películas, clientes, salas y préstamos.

### Requisitos
- Navegador web
- Backend corriendo en `localhost:8080`

### Ejecución

```bash
# 1. Clonar el repositorio
git clone https://github.com/vanessaperdomo/Frontend_Cine.git
cd Frontend_Cine
```

Abrir el archivo `cinema/index.html` directamente en el navegador,
o usar Live Server en VS Code para evitar problemas de CORS.

---

## 🚀 Orden de ejecución recomendado

```
1. BaseDeDatos_Cine  →  docker-compose up --build
2. Backend_API_Cine  →  mvn spring-boot:run
3. Frontend_Cine     →  abrir index.html en el navegador
```

---

## ✅ CI/CD

Los tres repositorios tienen GitHub Actions configurado.
Cada push a `main` o `develop` ejecuta el pipeline de validación automáticamente.
