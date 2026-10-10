package com.example.consulta.controller;

import com.example.consulta.api.PublicAccountsApi;
import com.example.consulta.exception.AccountNotFoundException;
import com.example.consulta.model.AccountStatusResponse;
import com.example.consulta.model.RecentPayment;
import com.example.consulta.model.RecentReading;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.RestController;

import java.time.LocalDate;
import java.math.BigDecimal;
import java.util.List;

@RestController
@Validated
public class PublicAccountsController implements PublicAccountsApi {

    @Override
    public ResponseEntity<AccountStatusResponse> getPublicAccountStatus(String meterCode) {
        if ("CNT-9999".equals(meterCode)) {
            throw new AccountNotFoundException();
        }

        AccountStatusResponse response = new AccountStatusResponse(
                "CNT-0001",
                "J*** P******",
                true,
                new BigDecimal("245.50"),
                List.of(new RecentReading(
                        LocalDate.of(2026, 9, 30),
                        18500,
                        new BigDecimal("245.50")
                ), new RecentReading(
                        LocalDate.of(2026, 8, 31),
                        17200,
                        new BigDecimal("220.75")
                )),
                List.of(new RecentPayment(
                        LocalDate.of(2026, 9, 15),
                        new BigDecimal("300.00"),
                        "REC-20260915-0001"
                ), new RecentPayment(
                        LocalDate.of(2026, 8, 15),
                        new BigDecimal("275.25"),
                        "REC-20260815-0001"
                ))
        );

        return ResponseEntity.ok(response);
    }
}
