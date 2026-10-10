package com.example.consulta.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import org.hibernate.annotations.Immutable;

import java.math.BigDecimal;
import java.time.LocalDate;

@Entity
@Immutable
@Table(name = "Tb_Lecturas")
public class Lectura {

    @Id
    @Column(name = "lectura_id", columnDefinition = "INT UNSIGNED")
    private Integer lecturaId;

    @Column(name = "fecha", nullable = false)
    private LocalDate fecha;

    @Column(name = "consumo_litros", nullable = false)
    private Integer consumoLitros;

    @Column(name = "monto_total", nullable = false, precision = 10, scale = 2)
    private BigDecimal montoTotal;

    @ManyToOne(fetch = FetchType.EAGER, optional = false)
    @JoinColumn(name = "contador_id", nullable = false, columnDefinition = "INT UNSIGNED")
    private Contador contador;

    protected Lectura() {
    }

    public Integer getLecturaId() {
        return lecturaId;
    }

    public LocalDate getFecha() {
        return fecha;
    }

    public Integer getConsumoLitros() {
        return consumoLitros;
    }

    public BigDecimal getMontoTotal() {
        return montoTotal;
    }

    public Contador getContador() {
        return contador;
    }
}
