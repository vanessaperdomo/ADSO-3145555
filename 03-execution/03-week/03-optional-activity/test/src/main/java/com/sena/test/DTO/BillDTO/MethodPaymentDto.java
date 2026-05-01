package com.sena.test.DTO.BillDTO;

import java.util.UUID;

public class MethodPaymentDto {

    private UUID id;
    private String name;

    public MethodPaymentDto() {
    }

    public UUID getId() {
        return id;
    }

    public void setId(UUID id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }
}