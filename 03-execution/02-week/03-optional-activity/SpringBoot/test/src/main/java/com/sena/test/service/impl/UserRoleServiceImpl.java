package com.sena.test.service.impl;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.sena.test.Repository.UserRoleRepository;
import com.sena.test.Repository.UserRepository;
import com.sena.test.Repository.RoleRepository;
import com.sena.test.entity.UserRole;
import com.sena.test.entity.UserRoleId;
import com.sena.test.entity.User;
import com.sena.test.entity.Role;
import com.sena.test.dto.UserRoleDto;
import com.sena.test.service.UserRoleService;

@Service
public class UserRoleServiceImpl implements UserRoleService {

    @Autowired
    private UserRoleRepository userRoleRepository;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private RoleRepository roleRepository;

    @Override
    public List<UserRole> findAll() {
        return userRoleRepository.findAll();
    }

    @Override
    public List<UserRole> findByUserId(Integer userId) {
        return userRoleRepository.findByUserId(userId);
    }

    @Override
    public List<UserRole> findByRoleId(Integer roleId) {
        return userRoleRepository.findByRoleId(roleId);
    }

    @Override
    public String save(UserRoleDto userRoleDto) {
        User user = userRepository.findById(userRoleDto.getIdUser()).orElse(null);
        Role role = roleRepository.findById(userRoleDto.getIdRole()).orElse(null);

        if (user == null)
            return "Usuario no encontrado";
        if (role == null)
            return "Rol no encontrado";

        UserRole userRole = new UserRole(user, role);
        userRoleRepository.save(userRole);
        return "Rol asignado al usuario exitosamente";
    }

    @Override
    public String delete(Integer idUser, Integer idRole) {
        UserRoleId id = new UserRoleId(idUser, idRole);
        if (!userRoleRepository.existsById(id)) {
            return "Registro no encontrado";
        }
        userRoleRepository.deleteById(id);
        return "Rol removido del usuario exitosamente";
    }
}