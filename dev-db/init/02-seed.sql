USE oficina_agua;
SET NAMES utf8mb4;

-- Catalogos base.
INSERT INTO Tb_Tipos_Servicio
    (tipo_servicio_id, tipo_servicio, litros_incluidos)
VALUES
    (1, 'Residencial', 12000),
    (2, 'Comercial', 30000);

INSERT INTO Tb_Metodos_Pago
    (metodos_pago_id, metodo)
VALUES
    (1, 'Efectivo'),
    (2, 'Transferencia'),
    (3, 'Tarjeta');

-- Usuarios ficticios de soporte para lecturas y pagos.
INSERT INTO Tb_Usuarios
    (usuario_id, nombre, email, password_hash, rol_id, activo, ultimo_acceso)
VALUES
    (1, 'Ana López', 'ana.lopez@example.test', 'seed-only-not-a-login-hash', 1, 1, NULL),
    (2, 'Bruno Méndez', 'bruno.mendez@example.test', 'seed-only-not-a-login-hash', 2, 1, NULL),
    (3, 'Carla Ruiz', 'carla.ruiz@example.test', 'seed-only-not-a-login-hash', 2, 1, NULL);

INSERT INTO Tb_Clientes
    (cliente_id, nombre, telefono, direccion)
VALUES
    (1, 'María González', '5550-1001', 'Avenida Central 10'),
    (2, 'Jorge Ramírez', '5550-1002', 'Calle del Parque 22'),
    (3, 'Sofía Castillo', '5550-1003', 'Colonia Las Flores 8'),
    (4, 'Diego Herrera', '5550-1004', 'Barrio El Centro 14'),
    (5, 'Elena Morales', '5550-1005', 'Pasaje Los Pinos 5'),
    (6, 'Álvarez', '5550-1006', 'Callejón del Río 3');

INSERT INTO Tb_Contadores
    (contador_id, numero_registro, direccion_servicio, estado, cliente_id, tipo_servicio_id)
VALUES
    (1, 'CNT-0001', 'Avenida Central 10', 1, 1, 1),
    (2, 'CNT-0002', 'Calle del Parque 22', 1, 2, 1),
    (3, 'CNT-0003', 'Colonia Las Flores 8', 1, 3, 1),
    (4, 'CNT-0004', 'Barrio El Centro 14', 1, 4, 1),
    (5, 'CNT-0005', 'Pasaje Los Pinos 5', 0, 5, 1),
    (6, 'CNT-0006', 'Callejón del Río 3', 1, 6, 2);

INSERT INTO Tb_Tarifas
    (tarifa_id, monto_por_unidad, vigente_desde, vigente_hasta, tipo_servicio_id)
VALUES
    (1, 0.0150, '2025-01-01', '2025-12-31', 1),
    (2, 0.0175, '2026-01-01', NULL, 1),
    (3, 0.0225, '2026-01-01', NULL, 2);

-- CNT-0001: ocho lecturas; las primeras seis están pagadas y las dos
-- más recientes quedan pendientes.
INSERT INTO Tb_Lecturas
    (lectura_id, lectura_anterior, lectura_actual, consumo_litros,
     litros_exceso, monto_base, monto_exceso, monto_total, fecha,
     contador_id, usuario_lector_id, tarifa_base_id, tarifa_exceso_id)
VALUES
    (1, 10000, 10800, 800, NULL, 12.00, NULL, 12.00, '2025-06-05', 1, 2, 1, NULL),
    (2, 10800, 11650, 850, NULL, 12.75, NULL, 12.75, '2025-07-05', 1, 2, 1, NULL),
    (3, 11650, 12500, 850, NULL, 12.75, NULL, 12.75, '2025-08-05', 1, 2, 1, NULL),
    (4, 12500, 13400, 900, NULL, 13.50, NULL, 13.50, '2025-09-05', 1, 2, 1, NULL),
    (5, 13400, 14400, 1000, NULL, 15.00, NULL, 15.00, '2025-10-05', 1, 2, 1, NULL),
    (6, 14400, 15400, 1000, NULL, 15.00, NULL, 15.00, '2025-11-05', 1, 2, 1, NULL),
    (7, 15400, 16500, 1100, NULL, 19.25, NULL, 19.25, '2026-01-05', 1, 2, 2, NULL),
    (8, 16500, 17700, 1200, NULL, 21.00, NULL, 21.00, '2026-02-05', 1, 2, 2, NULL);

-- CNT-0002: el pago fue anulado; la lectura sigue pendiente.
INSERT INTO Tb_Lecturas
    (lectura_id, lectura_anterior, lectura_actual, consumo_litros,
     litros_exceso, monto_base, monto_exceso, monto_total, fecha,
     contador_id, usuario_lector_id, tarifa_base_id, tarifa_exceso_id)
VALUES
    (9, 22000, 23200, 1200, NULL, 21.00, NULL, 21.00, '2026-02-05', 2, 2, 2, NULL);

-- CNT-0003: primero se anuló un pago y luego se registró uno activo.
INSERT INTO Tb_Lecturas
    (lectura_id, lectura_anterior, lectura_actual, consumo_litros,
     litros_exceso, monto_base, monto_exceso, monto_total, fecha,
     contador_id, usuario_lector_id, tarifa_base_id, tarifa_exceso_id)
VALUES
    (10, 31000, 32100, 1100, NULL, 19.25, NULL, 19.25, '2026-02-05', 3, 2, 2, NULL);

-- CNT-0006: todas sus lecturas están pagadas.
INSERT INTO Tb_Lecturas
    (lectura_id, lectura_anterior, lectura_actual, consumo_litros,
     litros_exceso, monto_base, monto_exceso, monto_total, fecha,
     contador_id, usuario_lector_id, tarifa_base_id, tarifa_exceso_id)
VALUES
    (11, 40000, 42000, 2000, NULL, 45.00, NULL, 45.00, '2025-12-05', 6, 2, 3, NULL),
    (12, 42000, 44200, 2200, NULL, 49.50, NULL, 49.50, '2026-01-05', 6, 2, 3, NULL),
    (13, 44200, 46500, 2300, NULL, 51.75, NULL, 51.75, '2026-02-05', 6, 2, 3, NULL);

-- Pagos activos de las seis lecturas más antiguas de CNT-0001.
INSERT INTO Tb_Pagos
    (pago_id, monto, fecha_pago, numero_recibo, lectura_id, usuario_id,
     metodos_pago_id, observaciones, anulado, anulado_at, anulado_por)
VALUES
    (1, 12.00, '2025-06-06', 'REC-000001', 1, 1, 1, NULL, 0, NULL, NULL),
    (2, 12.75, '2025-07-06', 'REC-000002', 2, 1, 1, NULL, 0, NULL, NULL),
    (3, 12.75, '2025-08-06', 'REC-000003', 3, 1, 2, NULL, 0, NULL, NULL),
    (4, 13.50, '2025-09-06', 'REC-000004', 4, 1, 1, NULL, 0, NULL, NULL),
    (5, 15.00, '2025-10-06', 'REC-000005', 5, 1, 3, NULL, 0, NULL, NULL),
    (6, 15.00, '2025-11-06', 'REC-000006', 6, 1, 1, NULL, 0, NULL, NULL);

-- Pago anulado de CNT-0002: lectura_activa_id queda NULL.
INSERT INTO Tb_Pagos
    (pago_id, monto, fecha_pago, numero_recibo, lectura_id, usuario_id,
     metodos_pago_id, observaciones, anulado, anulado_at, anulado_por)
VALUES
    (7, 21.00, '2026-02-06', 'REC-000007', 9, 1, 1,
     'Pago anulado por referencia incorrecta', 1, '2026-02-07 10:00:00', 1);

-- CNT-0003: pago anterior anulado y pago posterior activo.
INSERT INTO Tb_Pagos
    (pago_id, monto, fecha_pago, numero_recibo, lectura_id, usuario_id,
     metodos_pago_id, observaciones, anulado, anulado_at, anulado_por)
VALUES
    (8, 19.25, '2026-02-06', 'REC-000008', 10, 1, 2,
     'Pago anulado por comprobante ilegible', 1, '2026-02-07 11:00:00', 1),
    (9, 19.25, '2026-02-08', 'REC-000009', 10, 1, 2,
     'Nuevo pago posterior a la anulacion', 0, NULL, NULL);

-- Pagos de todas las lecturas de CNT-0006.
INSERT INTO Tb_Pagos
    (pago_id, monto, fecha_pago, numero_recibo, lectura_id, usuario_id,
     metodos_pago_id, observaciones, anulado, anulado_at, anulado_por)
VALUES
    (10, 45.00, '2025-12-06', 'REC-000010', 11, 1, 1, NULL, 0, NULL, NULL),
    (11, 49.50, '2026-01-06', 'REC-000011', 12, 1, 2, NULL, 0, NULL, NULL),
    (12, 51.75, '2026-02-06', 'REC-000012', 13, 1, 3, NULL, 0, NULL, NULL);

/*
Saldo pendiente esperado por contador:
  CNT-0001 = 40.25 (lecturas 7 y 8)
  CNT-0002 = 21.00 (su unico pago esta anulado)
  CNT-0003 = 0.00 (tiene un pago activo posterior a la anulacion)
  CNT-0004 = 0.00 (sin lecturas)
  CNT-0005 = 0.00 (medidor inactivo y sin lecturas)
  CNT-0006 = 0.00 (todas sus lecturas estan pagadas)
*/
