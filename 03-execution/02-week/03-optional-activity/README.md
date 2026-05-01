# Cafetín SENA — Backend API REST

Desarrollado por: Laura Vanessa Pérez Perdomo
Instructor: Jesús Airel González Bonilla
SENA — Centro de la Industria, la Empresa y los Servicios · Neiva, Huila · 2026

---

## Tecnologías

- Java 17
- Spring Boot 4.0.2
- PostgreSQL 15
- Maven
- Docker & Docker Compose

---

## Cómo levantar el proyecto

Requisito: tener Docker Desktop instalado y corriendo.

Desde la carpeta raíz del proyecto (donde está el docker-compose.yml):

    docker-compose up --build

Esto levanta automáticamente la base de datos PostgreSQL y la aplicación Spring Boot.

El servidor queda disponible en: http://localhost:8080
Las tablas se crean solas al iniciar gracias a ddl-auto=update.

Para detener:

    docker-compose down

---

## Qué se hizo

Se implementaron 4 entidades con CRUD completo: Person, Role, User y UserRole.

Cada entidad tiene:
- Entity      → representa la tabla en base de datos
- DTO         → objeto para recibir y enviar datos
- Repository  → acceso a base de datos con queries personalizadas
- Service     → interfaz con las operaciones disponibles
- ServiceImpl → implementación de la lógica de negocio
- Controller  → endpoints HTTP (GET, POST, PUT, DELETE)

Para UserRole se usó clave primaria compuesta con @EmbeddedId
ya que la tabla relaciona dos entidades (User y Role).

---

## Endpoints

| Entidad  | URL base      |
|----------|---------------|
| Person   | /api/person   |
| Role     | /role         |
| User     | /users        |
| UserRole | /user-role    |

Operaciones disponibles en cada una:
GET /          → listar todos
GET /{id}      → buscar por id
POST /         → crear
PUT /{id}      → actualizar
DELETE /{id}   → eliminar

## Cómo probar en Postman

1. Abrir Postman y crear una nueva petición
2. Seleccionar el método (GET, POST, PUT, DELETE)
3. Escribir la URL, ejemplo: http://localhost:8080/api/person
4. Para POST y PUT: ir a Body → raw → JSON y pegar el ejemplo
5. Clic en Send y verificar que responda 200 OK

---

Ejemplos de Body JSON por entidad:

### Person
{
  "nombre": "Laura Pérez",
  "telefono": "3101234567",
  "direccion": "Calle 5 # 10-20, Neiva",
  "correo": "laura@sena.edu.co"
}

### Role
{
  "nombre": "APRENDIZ"
}

### User
{
  "username": "laura.perez",
  "password": "Segura@123",
  "activo": true,
  "idPerson": 1
}

### UserRole
{
  "idUser": 1,
  "idRole": 1
}