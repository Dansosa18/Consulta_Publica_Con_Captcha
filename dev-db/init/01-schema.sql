CREATE DATABASE IF NOT EXISTS oficina_agua
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE oficina_agua;

CREATE TABLE Tb_Clientes (
    cliente_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    telefono VARCHAR(20) NULL,
    direccion VARCHAR(255) NOT NULL,
    PRIMARY KEY (cliente_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE Tb_Tipos_Servicio (
    tipo_servicio_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    tipo_servicio VARCHAR(50) NOT NULL,
    litros_incluidos INT NULL,
    PRIMARY KEY (tipo_servicio_id),
    UNIQUE KEY uk_tipos_servicio_nombre (tipo_servicio)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE Tb_Usuarios (
    usuario_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    rol_id INT UNSIGNED NOT NULL,
    activo BOOLEAN NOT NULL DEFAULT 1,
    ultimo_acceso DATETIME NULL,
    PRIMARY KEY (usuario_id),
    UNIQUE KEY uk_usuarios_email (email),
    KEY idx_usuarios_rol (rol_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE Tb_Metodos_Pago (
    metodos_pago_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    metodo VARCHAR(30) NOT NULL,
    PRIMARY KEY (metodos_pago_id),
    UNIQUE KEY uk_metodos_pago_nombre (metodo)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE Tb_Contadores (
    contador_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    numero_registro VARCHAR(50) NOT NULL,
    direccion_servicio VARCHAR(50) NOT NULL,
    estado BOOLEAN NOT NULL,
    cliente_id INT UNSIGNED NOT NULL,
    tipo_servicio_id INT UNSIGNED NOT NULL,
    PRIMARY KEY (contador_id),
    UNIQUE KEY uk_contadores_numero_registro (numero_registro),
    KEY idx_contadores_cliente (cliente_id),
    KEY idx_contadores_tipo_servicio (tipo_servicio_id),
    CONSTRAINT fk_contadores_cliente
        FOREIGN KEY (cliente_id) REFERENCES Tb_Clientes (cliente_id),
    CONSTRAINT fk_contadores_tipo_servicio
        FOREIGN KEY (tipo_servicio_id) REFERENCES Tb_Tipos_Servicio (tipo_servicio_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE Tb_Tarifas (
    tarifa_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    monto_por_unidad DECIMAL(10,2) NOT NULL,
    vigente_desde DATE NOT NULL,
    vigente_hasta DATE NULL,
    tipo_servicio_id INT UNSIGNED NOT NULL,
    PRIMARY KEY (tarifa_id),
    KEY idx_tarifas_tipo_servicio (tipo_servicio_id),
    CONSTRAINT fk_tarifas_tipo_servicio
        FOREIGN KEY (tipo_servicio_id) REFERENCES Tb_Tipos_Servicio (tipo_servicio_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE Tb_Lecturas (
    lectura_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    lectura_anterior INT NOT NULL,
    lectura_actual INT NOT NULL,
    consumo_litros INT NOT NULL,
    litros_exceso INT NULL,
    monto_base DECIMAL(10,2) NOT NULL,
    monto_exceso DECIMAL(10,2) NULL,
    monto_total DECIMAL(10,2) NOT NULL,
    fecha DATE NOT NULL,
    contador_id INT UNSIGNED NOT NULL,
    usuario_lector_id INT UNSIGNED NOT NULL,
    tarifa_base_id INT UNSIGNED NOT NULL,
    tarifa_exceso_id INT UNSIGNED NULL,
    PRIMARY KEY (lectura_id),
    UNIQUE KEY uk_lecturas_contador_fecha (contador_id, fecha),
    KEY idx_lecturas_contador (contador_id),
    KEY idx_lecturas_usuario_lector (usuario_lector_id),
    KEY idx_lecturas_tarifa_base (tarifa_base_id),
    KEY idx_lecturas_tarifa_exceso (tarifa_exceso_id),
    CONSTRAINT fk_lecturas_contador
        FOREIGN KEY (contador_id) REFERENCES Tb_Contadores (contador_id),
    CONSTRAINT fk_lecturas_usuario_lector
        FOREIGN KEY (usuario_lector_id) REFERENCES Tb_Usuarios (usuario_id),
    CONSTRAINT fk_lecturas_tarifa_base
        FOREIGN KEY (tarifa_base_id) REFERENCES Tb_Tarifas (tarifa_id),
    CONSTRAINT fk_lecturas_tarifa_exceso
        FOREIGN KEY (tarifa_exceso_id) REFERENCES Tb_Tarifas (tarifa_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE Tb_Pagos (
    pago_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    monto DECIMAL(10,2) NOT NULL,
    fecha_pago DATE NOT NULL,
    numero_recibo VARCHAR(20) NOT NULL,
    lectura_id INT UNSIGNED NOT NULL,
    usuario_id INT UNSIGNED NOT NULL,
    metodos_pago_id INT UNSIGNED NOT NULL,
    observaciones VARCHAR(255) NULL,
    anulado BOOLEAN NOT NULL DEFAULT 0,
    anulado_at DATETIME NULL,
    anulado_por INT UNSIGNED NULL,
    lectura_activa_id INT UNSIGNED
        GENERATED ALWAYS AS (
            CASE
                WHEN anulado = 0 THEN lectura_id
                ELSE NULL
            END
        ) STORED,
    PRIMARY KEY (pago_id),
    UNIQUE KEY uk_pagos_numero_recibo (numero_recibo),
    UNIQUE KEY uk_pagos_lectura_activa (lectura_activa_id),
    KEY idx_pagos_lectura (lectura_id),
    KEY idx_pagos_usuario (usuario_id),
    KEY idx_pagos_metodo (metodos_pago_id),
    KEY idx_pagos_anulado_por (anulado_por),
    CONSTRAINT fk_pagos_lectura
        FOREIGN KEY (lectura_id) REFERENCES Tb_Lecturas (lectura_id),
    CONSTRAINT fk_pagos_usuario
        FOREIGN KEY (usuario_id) REFERENCES Tb_Usuarios (usuario_id),
    CONSTRAINT fk_pagos_metodo
        FOREIGN KEY (metodos_pago_id) REFERENCES Tb_Metodos_Pago (metodos_pago_id),
    CONSTRAINT fk_pagos_anulado_por
        FOREIGN KEY (anulado_por) REFERENCES Tb_Usuarios (usuario_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
