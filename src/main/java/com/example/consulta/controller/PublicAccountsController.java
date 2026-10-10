package com.example.consulta.controller;

import com.example.consulta.api.PublicAccountsApi;
import com.example.consulta.service.AccountService;
import com.example.consulta.model.AccountStatusResponse;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.RestController;

@RestController
@Validated
public class PublicAccountsController implements PublicAccountsApi {

    private final AccountService accountService;

    public PublicAccountsController(AccountService accountService) {
        this.accountService = accountService;
    }

    @Override
    public ResponseEntity<AccountStatusResponse> getPublicAccountStatus(String meterCode) {
        return ResponseEntity.ok(accountService.getAccountStatus(meterCode));
    }
}
