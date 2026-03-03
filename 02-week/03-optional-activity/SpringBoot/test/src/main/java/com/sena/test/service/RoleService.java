package com.sena.test.service;

import java.util.List;
import com.sena.test.entity.Role;
import com.sena.test.dto.RoleDto;

public interface RoleService {

    public List<Role> findAll(); // findal: busca todas las personas

    public Role findById(int id); // findById: busca por id

    public List<Role> filterByName(String nombre); // filtra por el nombre

    public String save(RoleDto r); // save = guarde

    public String delete(int id); // aqui elimina por id

    public String update(int id, RoleDto r); // actualizar

}
