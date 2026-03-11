package com.sena.test.service.impl;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.sena.test.IRepository.RoleRepository;
import com.sena.test.entity.Role;
import com.sena.test.dto.RoleDto;
import com.sena.test.service.RoleService;

@Service
public class RoleServiceImpl implements RoleService {

    @Autowired
    private RoleRepository roleRepository;

    @Override
    public List<Role> findAll() {
        return this.roleRepository.findAll();
    }

    @Override
    public Role findById(int id) {
        return roleRepository.findById(id).orElse(null);
    }

    @Override
    public String save(RoleDto roleDto) {
        Role role = dtoToEntity(roleDto);
        roleRepository.save(role);
        return "Role guardada exitosamente";
    }

    @Override
    public String delete(int id) {
        roleRepository.deleteById(id);
        return "Role eliminada exitosamente";
    }

    @Override
    public List<Role> filterByName(String nombre) {
        return roleRepository.filterByName(nombre);
    }

    public Role dtoToEntity(RoleDto roleDto) {
        return new Role(
                roleDto.getId(),
                roleDto.getNombre());
    }

    public RoleDto entityToDto(Role role) {
        return new RoleDto(
                role.getId(),
                role.getNombre());
    }

    @Override
    public String update(int id, RoleDto roleDto) {
        Role role = roleRepository.findById(id).orElse(null);
        if (role != null) {
            role.setNombre(roleDto.getNombre());
            roleRepository.save(role);
            return "Role actualizada exitosamente";
        }
        return "Role no encontrada";
    }
}