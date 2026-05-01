package com.sena.test.DTO.SecurityDTO;

import java.util.UUID;

public class UserRoleDto {

    private UUID userId;
    private UUID roleId;

    public UserRoleDto() {
    }

    public UUID getUserId() {
        return userId;
    }

    public void setUserId(UUID userId) {
        this.userId = userId;
    }

    public UUID getRoleId() {
        return roleId;
    }

    public void setRoleId(UUID roleId) {
        this.roleId = roleId;
    }
}