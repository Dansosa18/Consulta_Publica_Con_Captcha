package com.example.consulta.service;

import com.example.consulta.entity.Contador;
import com.example.consulta.entity.Lectura;
import com.example.consulta.entity.Pago;
import com.example.consulta.model.AccountStatusResponse;
import com.example.consulta.model.RecentPayment;
import com.example.consulta.model.RecentReading;
import org.springframework.stereotype.Component;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.List;

@Component
public class AccountMapper {

    public AccountStatusResponse toResponse(
            Contador contador,
            BigDecimal pendingBalance,
            List<Lectura> lecturas,
            List<Pago> pagos
    ) {
        return new AccountStatusResponse(
                contador.getNumeroRegistro(),
                maskName(contador.getCliente().getNombre()),
                contador.isEstado(),
                scaleMoney(pendingBalance),
                lecturas.stream().map(this::toRecentReading).toList(),
                pagos.stream().map(this::toRecentPayment).toList()
        );
    }

    private RecentReading toRecentReading(Lectura lectura) {
        return new RecentReading(
                lectura.getFecha(),
                lectura.getConsumoLitros(),
                scaleMoney(lectura.getMontoTotal())
        );
    }

    private RecentPayment toRecentPayment(Pago pago) {
        return new RecentPayment(
                pago.getFechaPago(),
                scaleMoney(pago.getMonto()),
                pago.getNumeroRecibo()
        );
    }

    private String maskName(String name) {
        return java.util.Arrays.stream(name.trim().split("\\s+"))
                .map(this::maskWord)
                .collect(java.util.stream.Collectors.joining(" "));
    }

    private String maskWord(String word) {
        int firstCodePoint = word.codePointAt(0);
        int remainingCodePoints = word.codePointCount(0, word.length()) - 1;
        return new String(Character.toChars(firstCodePoint)) + "*".repeat(remainingCodePoints);
    }

    private BigDecimal scaleMoney(BigDecimal value) {
        return value == null
                ? BigDecimal.ZERO.setScale(2, RoundingMode.UNNECESSARY)
                : value.setScale(2, RoundingMode.HALF_UP);
    }
}
