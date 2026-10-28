USE oficina_agua;
SET NAMES utf8mb4;

-- Datos adicionales ficticios para pruebas manuales y de integración.
INSERT INTO Tb_Clientes
    (cliente_id, nombre, telefono, direccion)
VALUES
    (7, 'Núñez', '5550-1007', 'Calle Los Laureles 7'),
    (8, 'Valentina Paredes', '5550-1008', 'Avenida del Lago 18'),
    (9, 'Ricardo Salazar', '5550-1009', 'Calle Robles 29'),
    (10, 'Paola Cifuentes', '5550-1010', 'Pasaje El Mirador 4'),
    (11, 'Tomás Villanueva', '5550-1011', 'Colonia Las Brisas 11'),
    (12, 'Gabriela Ortega', '5550-1012', 'Boulevard Los Álamos 36'),
    (13, 'Héctor Cabrera', '5550-1013', 'Calle Las Palmas 42'),
    (14, 'Lucía Méndez', '5550-1014', 'Residencial La Arboleda 9'),
    (15, 'Samuel Ríos', '5550-1015', 'Avenida Los Pinos 55'),
    (16, 'Inés Calderón', '5550-1016', 'Calle del Sol 63');

INSERT INTO Tb_Contadores
    (contador_id, numero_registro, direccion_servicio, estado,
     cliente_id, tipo_servicio_id)
VALUES
    (7, 'CNT-0007', 'Calle Los Laureles 7', 1, 7, 1),
    (8, 'CNT-0008', 'Avenida del Lago 18', 1, 8, 1),
    (9, 'CNT-0009', 'Calle Robles 29', 1, 9, 1),
    (10, 'CNT-0010', 'Pasaje El Mirador 4', 1, 10, 2),
    (11, 'CNT-0011', 'Colonia Las Brisas 11', 0, 11, 1),
    (12, 'CNT-0012', 'Boulevard Los Álamos 36', 1, 12, 2),
    (13, 'CNT-0013', 'Calle Las Palmas 42', 1, 13, 1),
    (14, 'CNT-0014', 'Residencial La Arboleda 9', 1, 14, 2),
    (15, 'CNT-0015', 'Avenida Los Pinos 55', 1, 15, 1),
    (16, 'CNT-0016', 'Calle del Sol 63', 1, 16, 2);

-- CNT-0007: dos lecturas pagadas.
-- CNT-0008: una lectura pendiente.
-- CNT-0009: una lectura pendiente por pago anulado y otra pagada.
-- CNT-0010: contador sin lecturas.
-- CNT-0011: medidor inactivo con una lectura pendiente.
-- CNT-0012: tres lecturas pagadas.
-- CNT-0013: dos lecturas, una pagada y una pendiente.
-- CNT-0014: dos lecturas pendientes.
-- CNT-0015: dos lecturas pagadas y una pendiente.
-- CNT-0016: cuatro lecturas con saldo mixto.
INSERT INTO Tb_Lecturas
    (lectura_id, lectura_anterior, lectura_actual, consumo_litros,
     litros_exceso, monto_base, monto_exceso, monto_total, fecha,
     contador_id, usuario_lector_id, tarifa_base_id, tarifa_exceso_id)
VALUES
    (14, 1000, 1800, 800, NULL, 14.00, NULL, 14.00, '2025-12-10', 7, 2, 2, NULL),
    (15, 1800, 2700, 900, NULL, 15.75, NULL, 15.75, '2026-01-10', 7, 2, 2, NULL),
    (16, 5000, 6200, 1200, NULL, 21.00, NULL, 21.00, '2026-02-10', 8, 3, 2, NULL),
    (17, 7000, 7900, 900, NULL, 15.75, NULL, 15.75, '2026-01-10', 9, 2, 2, NULL),
    (18, 7900, 9000, 1100, NULL, 19.25, NULL, 19.25, '2026-02-10', 9, 2, 2, NULL),
    (19, 12000, 13500, 1500, NULL, 33.75, NULL, 33.75, '2026-02-10', 11, 3, 2, NULL),
    (20, 20000, 22000, 2000, NULL, 45.00, NULL, 45.00, '2025-12-10', 12, 2, 3, NULL),
    (21, 22000, 24300, 2300, NULL, 51.75, NULL, 51.75, '2026-01-10', 12, 2, 3, NULL),
    (22, 24300, 27000, 2700, NULL, 60.75, NULL, 60.75, '2026-02-10', 12, 2, 3, NULL),
    (23, 3000, 4100, 1100, NULL, 19.25, NULL, 19.25, '2026-02-10', 13, 3, 2, NULL),
    (24, 4100, 5400, 1300, NULL, 22.75, NULL, 22.75, '2026-03-10', 13, 3, 2, NULL),
    (25, 8000, 10000, 2000, NULL, 45.00, NULL, 45.00, '2026-01-10', 14, 2, 3, NULL),
    (26, 10000, 12500, 2500, NULL, 56.25, NULL, 56.25, '2026-02-10', 14, 2, 3, NULL),
    (27, 15000, 16000, 1000, NULL, 17.50, NULL, 17.50, '2025-12-10', 15, 3, 2, NULL),
    (28, 16000, 17400, 1400, NULL, 24.50, NULL, 24.50, '2026-01-10', 15, 3, 2, NULL),
    (29, 17400, 19000, 1600, NULL, 28.00, NULL, 28.00, '2026-02-10', 15, 3, 2, NULL),
    (30, 25000, 26000, 1000, NULL, 22.50, NULL, 22.50, '2025-10-10', 16, 2, 3, NULL),
    (31, 26000, 27800, 1800, NULL, 40.50, NULL, 40.50, '2025-11-10', 16, 2, 3, NULL),
    (32, 27800, 30000, 2200, NULL, 49.50, NULL, 49.50, '2025-12-10', 16, 2, 3, NULL),
    (33, 30000, 32400, 2400, NULL, 54.00, NULL, 54.00, '2026-01-10', 16, 2, 3, NULL);

INSERT INTO Tb_Pagos
    (pago_id, monto, fecha_pago, numero_recibo, lectura_id, usuario_id,
     metodos_pago_id, observaciones, anulado, anulado_at, anulado_por)
VALUES
    (13, 14.00, '2025-12-11', 'REC-000013', 14, 1, 1, NULL, 0, NULL, NULL),
    (14, 15.75, '2026-01-11', 'REC-000014', 15, 1, 2, NULL, 0, NULL, NULL),
    (15, 15.75, '2026-01-11', 'REC-000015', 17, 1, 1,
     'Pago anulado por referencia incorrecta', 1, '2026-01-12 09:00:00', 1),
    (16, 19.25, '2026-02-11', 'REC-000016', 18, 1, 3, NULL, 0, NULL, NULL),
    (17, 45.00, '2025-12-11', 'REC-000017', 20, 1, 1, NULL, 0, NULL, NULL),
    (18, 51.75, '2026-01-11', 'REC-000018', 21, 1, 2, NULL, 0, NULL, NULL),
    (19, 60.75, '2026-02-11', 'REC-000019', 22, 1, 3, NULL, 0, NULL, NULL),
    (20, 19.25, '2026-02-11', 'REC-000020', 23, 1, 1, NULL, 0, NULL, NULL),
    (21, 17.50, '2025-12-11', 'REC-000021', 27, 1, 2, NULL, 0, NULL, NULL),
    (22, 24.50, '2026-01-11', 'REC-000022', 28, 1, 3, NULL, 0, NULL, NULL);

/*
Resumen esperado de los casos adicionales:
  CNT-0007 = 0.00 (dos lecturas pagadas)
  CNT-0008 = 21.00 (una lectura pendiente)
  CNT-0009 = 15.75 (pago de lectura 17 anulado; lectura 18 pagada)
  CNT-0010 = 0.00 (sin lecturas)
  CNT-0011 = 33.75 (medidor inactivo con deuda)
  CNT-0012 = 0.00 (tres lecturas pagadas)
  CNT-0013 = 22.75 (una lectura pagada y otra pendiente)
  CNT-0014 = 101.25 (dos lecturas pendientes)
  CNT-0015 = 28.00 (dos lecturas pagadas y una pendiente)
  CNT-0016 = 166.50 (una lectura pagada y tres pendientes)
*/
