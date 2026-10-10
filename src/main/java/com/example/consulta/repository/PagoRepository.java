package com.example.consulta.repository;

import com.example.consulta.entity.Pago;
import org.springframework.data.repository.Repository;
import org.springframework.data.repository.query.Param;
import org.springframework.data.jpa.repository.Query;

import java.math.BigDecimal;
import java.util.List;

public interface PagoRepository extends Repository<Pago, Integer> {

    @Query("""
            select coalesce(sum(l.montoTotal), 0)
            from Lectura l
            where l.contador.contadorId = :contadorId
              and not exists (
                  select p.pagoId
                  from Pago p
                  where p.lectura.lecturaId = l.lecturaId
                    and p.anulado = false
              )
            """)
    BigDecimal sumPendingBalanceByContadorId(@Param("contadorId") Integer contadorId);

    @Query("""
            select p
            from Pago p
            where p.lectura.contador.contadorId = :contadorId
              and p.anulado = false
            order by p.fechaPago desc
            """)
    List<Pago> findRecentActiveByContadorId(@Param("contadorId") Integer contadorId,
                                             org.springframework.data.domain.Pageable pageable);
}
