package com.example.consulta.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import org.hibernate.annotations.Immutable;

@Entity
@Immutable
@Table(name = "Tb_Contadores")
public class Contador {

    @Id
    @Column(name = "contador_id", columnDefinition = "INT UNSIGNED")
    private Integer contadorId;

    @Column(name = "numero_registro", nullable = false, length = 50)
    private String numeroRegistro;

    @Column(name = "estado", nullable = false)
    private boolean estado;

    @ManyToOne(fetch = FetchType.EAGER, optional = false)
    @JoinColumn(name = "cliente_id", nullable = false, columnDefinition = "INT UNSIGNED")
    private Cliente cliente;

    protected Contador() {
    }

    public Integer getContadorId() {
        return contadorId;
    }

    public String getNumeroRegistro() {
        return numeroRegistro;
    }

    public boolean isEstado() {
        return estado;
    }

    public Cliente getCliente() {
        return cliente;
    }
}
