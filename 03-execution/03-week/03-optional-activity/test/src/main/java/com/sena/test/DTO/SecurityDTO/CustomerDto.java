package com.sena.test.DTO.SecurityDTO;

import java.util.UUID;

public class CustomerDto {

    private UUID id;
    private UUID personId;
    private UUID customerTypeId;

    public CustomerDto() {
    }

    public UUID getId() {
        return id;
    }

    public void setId(UUID id) {
        this.id = id;
    }

    public UUID getPersonId() {
        return personId;
    }

    public void setPersonId(UUID personId) {
        this.personId = personId;
    }

    public UUID getCustomerTypeId() {
        return customerTypeId;
    }

    public void setCustomerTypeId(UUID customerTypeId) {
        this.customerTypeId = customerTypeId;
    }
}