package com.example.consulta.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import org.hibernate.annotations.Immutable;

@Entity
@Immutable
@Table(name = "Tb_Clientes")
public class Cliente {

    @Id
    @Column(name = "cliente_id", columnDefinition = "INT UNSIGNED")
    private Integer clienteId;

    @Column(name = "nombre", nullable = false)
    private String nombre;

    protected Cliente() {
    }

    public Integer getClienteId() {
        return clienteId;
    }

    public String getNombre() {
        return nombre;
    }
}
