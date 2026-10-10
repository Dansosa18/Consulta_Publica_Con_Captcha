package com.example.consulta.service;

import com.example.consulta.entity.Contador;
import com.example.consulta.exception.AccountNotFoundException;
import com.example.consulta.model.AccountStatusResponse;
import com.example.consulta.repository.ContadorRepository;
import com.example.consulta.repository.LecturaRepository;
import com.example.consulta.repository.PagoRepository;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;

@Service
@Transactional(readOnly = true)
public class AccountService {

    private final ContadorRepository contadorRepository;
    private final LecturaRepository lecturaRepository;
    private final PagoRepository pagoRepository;
    private final AccountMapper accountMapper;

    public AccountService(
            ContadorRepository contadorRepository,
            LecturaRepository lecturaRepository,
            PagoRepository pagoRepository,
            AccountMapper accountMapper
    ) {
        this.contadorRepository = contadorRepository;
        this.lecturaRepository = lecturaRepository;
        this.pagoRepository = pagoRepository;
        this.accountMapper = accountMapper;
    }

    public AccountStatusResponse getAccountStatus(String meterCode) {
        Contador contador = contadorRepository.findByNumeroRegistro(meterCode)
                .orElseThrow(AccountNotFoundException::new);
        Integer contadorId = contador.getContadorId();
        BigDecimal pendingBalance = pagoRepository.sumPendingBalanceByContadorId(contadorId);

        return accountMapper.toResponse(
                contador,
                pendingBalance,
                lecturaRepository.findTop6ByContadorContadorIdOrderByFechaDesc(contadorId),
                pagoRepository.findRecentActiveByContadorId(contadorId, PageRequest.of(0, 6))
        );
    }
}
