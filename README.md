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

## Rate limit

El endpoint público permite por defecto 10 solicitudes por minuto por IP.
La capacidad y el intervalo son configurables en
`src/main/resources/application.properties`:

```properties
ratelimit.capacity=10
ratelimit.refill-seconds=60
```

Cuando se excede el límite, responde `429` con un `ErrorResponse` y el header
`Retry-After`, indicando los segundos reales hasta el siguiente cupo. Las
solicitudes que llegan al endpoint, incluidas las que terminan en `400`, se
consideran para el límite.

La IP se obtiene mediante `request.getRemoteAddr()`. No se acepta
`X-Forwarded-For` directamente porque puede falsificarse. Al integrar Next.js
o nginx, se deberá configurar una lista explícita de proxies confiables antes
de considerar ese header para recuperar la IP original.

## Estado actual

- El Controller delega la consulta al Service, que lee la base de datos en
  modo solo lectura con `ddl-auto: validate`.
- El rate limit por IP está implementado con expiración de entradas inactivas.
- Falta la integración con Next.js.

## Reglas

- No modificar el monolito.
- No editar el código generado.
- No exponer datos privados.
