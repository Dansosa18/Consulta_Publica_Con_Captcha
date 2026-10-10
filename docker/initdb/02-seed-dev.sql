USE oficina_agua;

INSERT INTO Tb_Roles (rol_id, nombre)
VALUES (1, 'Operador de desarrollo');

INSERT INTO Tb_Clientes (cliente_id, nombre, telefono, direccion)
VALUES (1, 'Juan Pérez', '555-0101', 'Dirección ficticia 123');

INSERT INTO Tb_Tipos_Servicio (tipo_servicio_id, tipo_servicio, litros_incluidos)
VALUES (1, 'Doméstico', 10000);

INSERT INTO Tb_Usuarios (
    usuario_id, nombre, email, password_hash, rol_id, activo
)
VALUES (
    1, 'Usuario de desarrollo', 'dev@example.invalid',
    'hash-ficticio-no-utilizable', 1, 1
);

INSERT INTO Tb_Tarifas (
    tarifa_id, monto_por_unidad, vigente_desde, vigente_hasta, tipo_servicio_id
)
VALUES
    (1, 0.01, '2026-01-01', NULL, 1);

INSERT INTO Tb_Metodos_Pago (metodos_pago_id, metodo)
VALUES (1, 'Transferencia');

INSERT INTO Tb_Contadores (
    contador_id, numero_registro, direccion_servicio, estado,
    cliente_id, tipo_servicio_id
)
VALUES (
    1, 'CNT-0001', 'Dirección ficticia 123', 1, 1, 1
);

INSERT INTO Tb_Lecturas (
    lectura_id, lectura_anterior, lectura_actual, consumo_litros,
    litros_exceso, monto_base, monto_exceso, monto_total, fecha,
    contador_id, usuario_lector_id, tarifa_base_id, tarifa_exceso_id
)
VALUES
    (1, 1000, 12000, 11000, NULL, 110.00, NULL, 110.00, '2026-09-30', 1, 1, 1, NULL),
    (2, 12000, 22500, 10500, NULL, 105.00, NULL, 105.00, '2026-08-31', 1, 1, 1, NULL),
    (3, 22500, 33000, 10500, NULL, 95.00, NULL, 95.00, '2026-07-31', 1, 1, 1, NULL),
    (4, 33000, 43000, 10000, NULL, 90.00, NULL, 90.00, '2026-06-30', 1, 1, 1, NULL),
    (5, 43000, 53500, 10500, NULL, 85.00, NULL, 85.00, '2026-05-31', 1, 1, 1, NULL),
    (6, 53500, 64000, 10500, NULL, 80.00, NULL, 80.00, '2026-04-30', 1, 1, 1, NULL);

INSERT INTO Tb_Pagos (
    pago_id, monto, fecha_pago, numero_recibo, lectura_id,
    usuario_id, metodos_pago_id, observaciones, anulado
)
VALUES
    (1, 110.00, '2026-10-02', 'REC-DEV-0001', 1, 1, 1, NULL, 0),
    (2, 105.00, '2026-09-03', 'REC-DEV-0002', 2, 1, 1, 'Pago anulado para pruebas', 1),
    (3, 95.00, '2026-08-03', 'REC-DEV-0003', 3, 1, 1, NULL, 0);
