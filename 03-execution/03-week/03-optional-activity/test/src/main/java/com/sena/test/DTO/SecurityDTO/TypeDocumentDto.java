package com.sena.test.DTO.SecurityDTO;

import java.util.UUID;

public class TypeDocumentDto {

    private UUID id;
    private String name;

    public TypeDocumentDto() {
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