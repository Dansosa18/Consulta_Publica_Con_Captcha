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
@Table(name = "Tb_Pagos")
public class Pago {

    @Id
    @Column(name = "pago_id", columnDefinition = "INT UNSIGNED")
    private Integer pagoId;

    @ManyToOne(fetch = FetchType.EAGER, optional = false)
    @JoinColumn(name = "lectura_id", nullable = false, columnDefinition = "INT UNSIGNED")
    private Lectura lectura;

    @Column(name = "fecha_pago", nullable = false)
    private LocalDate fechaPago;

    @Column(name = "monto", nullable = false, precision = 10, scale = 2)
    private BigDecimal monto;

    @Column(name = "numero_recibo", nullable = false, length = 20)
    private String numeroRecibo;

    @Column(name = "anulado", nullable = false)
    private boolean anulado;

    protected Pago() {
    }

    public Integer getPagoId() {
        return pagoId;
    }

    public Lectura getLectura() {
        return lectura;
    }

    public LocalDate getFechaPago() {
        return fechaPago;
    }

    public BigDecimal getMonto() {
        return monto;
    }

    public String getNumeroRecibo() {
        return numeroRecibo;
    }

    public boolean isAnulado() {
        return anulado;
    }
}
