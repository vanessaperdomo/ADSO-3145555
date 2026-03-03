package com.sena.test.dto;

public class UserDto {

    private Integer idUser;
    private String username;
    private String password;
    private Boolean activo;
    private Integer idPerson;

    public UserDto() {

    }

    public UserDto(Integer idUser, String username, String password, Boolean activo, Integer idPerson) {
        this.idUser = idUser;
        this.username = username;
        this.password = password;
        this.activo = activo;
        this.idPerson = idPerson;
    }

    public Integer getIdUser() {
        return idUser;
    }

    public void setIdUser(Integer idUser) {
        this.idUser = idUser;
    }

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public Boolean getActivo() {
        return activo;
    }

    public void setActivo(Boolean activo) {
        this.activo = activo;
    }

    public Integer getIdPerson() {
        return idPerson;
    }

    public void setIdPerson(Integer idPerson) {
        this.idPerson = idPerson;
    }
}
