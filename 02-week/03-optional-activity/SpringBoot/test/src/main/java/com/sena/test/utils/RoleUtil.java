package com.sena.test.utils;

import com.sena.test.dto.RoleDto;
import com.sena.test.entity.Role;

public class RoleUtil {

    // Convierte RoleDto → Role
    // Se usa cuando el controller recibe datos y se van a guardar en la base de
    // datos
    public static Role dtoToEntity(RoleDto dto) {

        Role role = new Role();

        role.setId(dto.getId());
        role.setNombre(dto.getNombre());

        return role;
    }

    // Convierte Role → RoleDto
    // Se usa cuando se envían datos desde la base de datos al controller
    public static RoleDto entityToDto(Role role) {

        RoleDto dto = new RoleDto();

        dto.setId(role.getId());
        dto.setNombre(role.getNombre());

        return dto;
    }

}