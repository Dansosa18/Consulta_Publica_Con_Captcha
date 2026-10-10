package com.example.consulta.repository;

import com.example.consulta.entity.Lectura;
import org.springframework.data.repository.Repository;

import java.util.List;

public interface LecturaRepository extends Repository<Lectura, Integer> {

    List<Lectura> findTop6ByContadorContadorIdOrderByFechaDesc(Integer contadorId);
}
