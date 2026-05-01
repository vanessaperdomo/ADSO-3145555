package com.sena.test.DTO.SecurityDTO;

import java.util.UUID;

public class RoleDto {

    private UUID id;
    private String roleName;

    public RoleDto() {
    }

    public UUID getId() {
        return id;
    }

    public void setId(UUID id) {
        this.id = id;
    }

    public String getRoleName() {
        return roleName;
    }

    public void setRoleName(String roleName) {
        this.roleName = roleName;
    }
}