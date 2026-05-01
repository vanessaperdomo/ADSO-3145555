package com.sena.test.dto;

public class UserRoleDto {

    private Integer idUser;
    private Integer idRole;

    public UserRoleDto() {
    }

    public UserRoleDto(Integer idUser, Integer idRole) {
        this.idUser = idUser;
        this.idRole = idRole;
    }

    public Integer getIdUser() {
        return idUser;
    }

    public void setIdUser(Integer idUser) {
        this.idUser = idUser;
    }

    public Integer getIdRole() {
        return idRole;
    }

    public void setIdRole(Integer idRole) {
        this.idRole = idRole;
    }
}