```markdown
# CafetinSena - Backend API REST

Proyecto Spring Boot con PostgreSQL para la gestión del cafetín del SENA.

---

## 🛠️ Tecnologías

- Java 17
- Spring Boot 3.4.5
- PostgreSQL 17
- Docker
- Maven

---

## 📁 Estructura del proyecto

```
src/main/java/com/sena/test/
├── Controller/
│   ├── BillController/
│   ├── InventoryController/
│   └── SecurityController/
├── DTO/
├── Entity/
├── IRepository/
├── IService/
├── Service/
└── Utils/
```

---

## 🚀 Cómo levantar el proyecto

### 1. Levantar la base de datos

Tener Docker Desktop abierto, luego ejecutar en la terminal dentro de la carpeta del proyecto:

```bash
docker-compose up -d
```

Verificar que esté corriendo:

```bash
docker ps
```

Debe aparecer el contenedor `cafetinsenafull` en el puerto `5434`.

### 2. Correr el proyecto

Abrir el proyecto en IntelliJ, buscar el archivo:

```
src/main/java/com/sena/test/TestApplication.java
```

Clic derecho → **Run 'TestApplication'**

Cuando en la consola aparezca:

```
Tomcat started on port 8080
Started TestApplication
```

El servidor está listo en `http://localhost:8080`

---

## 📮 Pruebas en Postman

> En cada petición POST/PUT agregar en Headers:
> `Content-Type: application/json`

> Seguir este orden ya que hay dependencias entre tablas.

### 1. TypeDocument
```
POST http://localhost:8080/api/type-document
{"name": "Cédula"}
```

### 2. AcademicProgram
```
POST http://localhost:8080/api/academic-program
{"programName": "ADSO"}
```

### 3. StudyGroup
```
POST http://localhost:8080/api/study-group
{"groupCode": "FICHA-2758452", "academicProgramId": "UUID-ACADEMIC-PROGRAM"}
```

### 4. Person
```
POST http://localhost:8080/api/person
{
  "firstName": "Laura",
  "lastName": "Pérez",
  "documentNumber": "1234567890",
  "email": "laura@correo.com",
  "phone": "3001234567",
  "typeDocumentId": "UUID-TYPE-DOCUMENT",
  "studyGroupId": "UUID-STUDY-GROUP"
}
```

### 5. Users
```
POST http://localhost:8080/api/users
{"username": "laurap", "password": "123456", "active": true, "personId": "UUID-PERSON"}
```

### 6. Role
```
POST http://localhost:8080/api/role
{"roleName": "ADMIN"}
```

### 7. UserRole
```
POST http://localhost:8080/api/user-role
{"userId": "UUID-USERS", "roleId": "UUID-ROLE"}
```

### 8. CustomerType
```
POST http://localhost:8080/api/customer-type
{"name": "Aprendiz"}
```

### 9. Customer
```
POST http://localhost:8080/api/customer
{"personId": "UUID-PERSON", "customerTypeId": "UUID-CUSTOMER-TYPE"}
```

### 10. Category
```
POST http://localhost:8080/api/category
{"name": "Bebidas"}
```

### 11. Supplier
```
POST http://localhost:8080/api/supplier
{"name": "Proveedor ABC"}
```

### 12. Product
```
POST http://localhost:8080/api/product
{
  "name": "Café",
  "description": "Café negro caliente",
  "price": 2500.00,
  "stock": 50,
  "imageUrl": "https://imagen.com/cafe.jpg",
  "categoryId": "UUID-CATEGORY",
  "supplierId": "UUID-SUPPLIER"
}
```

### 13. InventoryMovement
```
POST http://localhost:8080/api/inventory-movement
{"movementType": "ENTRADA", "quantity": 10, "productId": "UUID-PRODUCT", "createdBy": "UUID-USERS"}
```

### 14. MemoryGameItem
```
POST http://localhost:8080/api/memory-game-item
{"englishName": "Coffee", "imageUrl": "https://imagen.com/coffee.jpg", "productId": "UUID-PRODUCT"}
```

### 15. OrderStatus
```
POST http://localhost:8080/api/order-status
{"name": "PENDIENTE"}
```

### 16. Orders
```
POST http://localhost:8080/api/orders
{"totalAmount": 7500.00, "statusId": "UUID-ORDER-STATUS", "customerId": "UUID-CUSTOMER"}
```

### 17. OrderItem
```
POST http://localhost:8080/api/order-item
{"orderId": "UUID-ORDERS", "productId": "UUID-PRODUCT", "quantity": 3, "unitPrice": 2500.00}
```

### 18. Invoice
```
POST http://localhost:8080/api/invoice
{"invoiceNumber": "FAC-001", "total": 7500.00, "orderId": "UUID-ORDERS"}
```

### 19. InvoiceItem
```
POST http://localhost:8080/api/invoice-item
{"invoiceId": "UUID-INVOICE", "productId": "UUID-PRODUCT", "quantity": 3, "price": 2500.00}
```

### 20. MethodPayment
```
POST http://localhost:8080/api/method-payment
{"name": "Efectivo"}
```

### 21. Payment
```
POST http://localhost:8080/api/payment
{"amountPaid": 7500.00, "invoiceId": "UUID-INVOICE", "methodPaymentId": "UUID-METHOD-PAYMENT"}
```

---

## ⚙️ Configuración

**docker-compose.yml**
```yaml
services:
  postgres:
    image: postgres:17
    container_name: cafetinsenafull
    environment:
      POSTGRES_DB: cafetinsena
      POSTGRES_USER: laura
      POSTGRES_PASSWORD: 12345
    ports:
      - "5434:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
volumes:
  postgres_data:
```

**application.properties**
```properties
spring.application.name=cafetinsena
spring.datasource.url=jdbc:postgresql://localhost:5434/cafetinsena
spring.datasource.username=laura
spring.datasource.password=12345
spring.datasource.driver-class-name=org.postgresql.Driver
spring.jpa.hibernate.ddl-auto=update
spring.jpa.show-sql=true
```

---

