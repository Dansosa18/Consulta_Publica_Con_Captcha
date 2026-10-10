package com.example.consulta.repository;

import com.example.consulta.entity.Contador;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.Repository;
import org.springframework.data.repository.query.Param;

import java.util.Optional;

public interface ContadorRepository extends Repository<Contador, Integer> {

    @Query("""
            select c
            from Contador c
            join fetch c.cliente
            where c.numeroRegistro = :numeroRegistro
            """)
    Optional<Contador> findByNumeroRegistro(@Param("numeroRegistro") String numeroRegistro);
}
