package com.sena.test.entity;

import java.io.Serializable;
import java.util.Objects;

public class UserRoleId implements Serializable {

    private static final long serialVersionUID = 1L; // ← agregar esta línea

    private Integer user;
    private Integer role;

    public UserRoleId() {
    }

    public UserRoleId(Integer user, Integer role) {
        this.user = user;
        this.role = role;
    }

    public Integer getUser() {
        return user;
    }

    public void setUser(Integer user) {
        this.user = user;
    }

    public Integer getRole() {
        return role;
    }

    public void setRole(Integer role) {
        this.role = role;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o)
            return true;
        if (!(o instanceof UserRoleId))
            return false;
        UserRoleId that = (UserRoleId) o;
        return Objects.equals(user, that.user) && Objects.equals(role, that.role);
    }

    @Override
    public int hashCode() {
        return Objects.hash(user, role);
    }
}