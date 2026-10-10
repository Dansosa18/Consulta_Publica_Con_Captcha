# consulta-service

Microservicio de consulta pública de estado de cuenta por código de medidor
(Feature 01, Fase 2). Es de solo lectura sobre la base de datos del monolito
`sistema-oficina-agua-1`, que no se modifica.

## Stack

- Java 17
- Spring Boot 3.5
- Maven
- Spring Data JPA
- MariaDB
- OpenAPI Generator (contract-first)

## Ejecución

Desde la raíz del proyecto:

```powershell
mvn clean compile
mvn spring-boot:run
```

El servicio utiliza el puerto `8081`.

## Contrato y código generado

El contrato OpenAPI es la fuente de verdad:

```text
src/main/resources/openapi/consulta-api.yaml
```

El código generado queda en `target/`. No se edita ni se versiona.

## Endpoint

```text
GET /api/v1/public/accounts/{meterCode}
```

Respuestas contempladas: `200`, `400`, `404`, `429` y `500`.

Ejemplo:

```text
GET http://localhost:8081/api/v1/public/accounts/CNT-0001
```

## Estado actual

- El Controller devuelve datos fijos.
- Falta conectar la base de datos en modo solo lectura con `ddl-auto: validate`.
- Falta implementar el rate limit por IP.
- Falta la integración con Next.js.

## Reglas

- No modificar el monolito.
- No editar el código generado.
- No exponer datos privados.
