
# 🚀 Spring Boot + PostgreSQL con Docker + CRUD Básica

## 📌 ¿Qué hace este proyecto?
API REST construida con **Spring Boot** que implementa una CRUD básica (Crear, Leer, Actualizar, Eliminar) para la gestión de personas, usuarios y roles. La base de datos es **PostgreSQL** y todo corre en contenedores **Docker**.

### Entidades principales
- **Person** — datos personales (nombre, correo, teléfono, dirección)
- **Role** — roles del sistema (ADMIN, USER, etc.)
- **User** — usuarios vinculados a una persona
- **UserRole** — asignación de roles a usuarios

---

## Requisitos previos
- Docker Desktop instalado y corriendo
- Postman (para probar la API)

---

## ▶️ Cómo levantar el proyecto

### 1. Abrir terminal en la carpeta correcta
```bash
cd 03-optional-activity/SpringBoot/test
```

### 2. Levantar los contenedores
```bash
docker compose up --build
```

### 3. Verificar que esté corriendo
Cuando veas esto en la terminal, ya está listo:
```
Started TestApplication in XX seconds
```

---

## ⏹️ Cómo bajar el proyecto
```bash
docker compose down
```

---

## 🐳 Contenedores que se levantan
| Contenedor | Descripción | Puerto |
|---|---|---|
| `postgres_cafeteria` | Base de datos PostgreSQL | 5432 |
| `springboot_app` | API REST Spring Boot | 8080 |

---

## 🔗 Endpoints disponibles

### 👤 Person
| Método | URL | Descripción |
|---|---|---|
| GET | `http://localhost:8080/api/person` | Listar todas |
| GET | `http://localhost:8080/api/person/{id}` | Buscar por ID |
| GET | `http://localhost:8080/api/person/filter/{nombre}` | Filtrar por nombre |
| POST | `http://localhost:8080/api/person` | Crear persona |
| PUT | `http://localhost:8080/api/person/{id}` | Actualizar persona |
| DELETE | `http://localhost:8080/api/person/{id}` | Eliminar persona |

### 🏷️ Role
| Método | URL | Descripción |
|---|---|---|
| GET | `http://localhost:8080/role` | Listar todos |
| GET | `http://localhost:8080/role/{id}` | Buscar por ID |
| POST | `http://localhost:8080/role` | Crear rol |
| PUT | `http://localhost:8080/role/{id}` | Actualizar rol |
| DELETE | `http://localhost:8080/role/{id}` | Eliminar rol |

### 👥 Users
| Método | URL | Descripción |
|---|---|---|
| GET | `http://localhost:8080/users` | Listar todos |
| GET | `http://localhost:8080/users/{id}` | Buscar por ID |
| POST | `http://localhost:8080/users` | Crear usuario |
| PUT | `http://localhost:8080/users/{id}` | Actualizar usuario |
| DELETE | `http://localhost:8080/users/{id}` | Eliminar usuario |

### 🔗 UserRole
| Método | URL | Descripción |
|---|---|---|
| GET | `http://localhost:8080/userrole` | Listar todos |
| GET | `http://localhost:8080/userrole/user/{idUser}` | Roles de un usuario |
| GET | `http://localhost:8080/userrole/role/{idRole}` | Usuarios de un rol |
| POST | `http://localhost:8080/userrole` | Asignar rol a usuario |
| DELETE | `http://localhost:8080/userrole/{idUser}/{idRole}` | Quitar rol a usuario |

---

## 📦 Ejemplos de Body para POST

### Person
```json
{
    "nombre": "Laura",
    "correo": "laura@gmail.com",
    "telefono": "3001234567",
    "direccion": "Calle 123"
}
```

### Role
```json
{
    "nombre": "ADMIN"
}
```

### User
```json
{
    "username": "laura123",
    "password": "12345",
    "activo": true,
    "idPerson": 1
}
```

### UserRole
```json
{
    "idUser": 1,
    "idRole": 1
}
```

---

## ⚠️ Notas importantes
- Crear siempre en este orden: **Person → Role → User → UserRole**
- El `idPerson` en User debe existir previamente en la tabla Person
- El `idUser` e `idRole` en UserRole deben existir previamente
```
