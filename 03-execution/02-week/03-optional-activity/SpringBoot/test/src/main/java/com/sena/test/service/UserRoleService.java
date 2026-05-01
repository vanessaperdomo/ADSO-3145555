package com.sena.test.service;

import java.util.List;
import com.sena.test.entity.UserRole;
import com.sena.test.dto.UserRoleDto;

public interface UserRoleService {

    public List<UserRole> findAll(); // busca todos los registros

    public List<UserRole> findByUserId(Integer userId); // todos los roles de un usuario

    public List<UserRole> findByRoleId(Integer roleId); // todos los usuarios con un rol

    public String save(UserRoleDto ur); // asignar rol a usuario

    public String delete(Integer idUser, Integer idRole); // quitar rol a usuario

}