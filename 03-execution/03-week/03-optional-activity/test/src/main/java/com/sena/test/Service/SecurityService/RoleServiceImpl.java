package com.sena.test.Service.SecurityService;

import java.util.ArrayList;
import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import com.sena.test.DTO.SecurityDTO.RoleDTO;
import com.sena.test.Entity.Security.Role;
import com.sena.test.IRepository.ISecurityRepository.IRoleRepository;
import com.sena.test.IService.ISecurityService.IRoleService;

@Service
public class RoleServiceImpl implements IRoleService {

    @Autowired
    private IRoleRepository roleRepository; // acceso a BD

    private RoleDTO mapToDTO(Role role) {
        RoleDTO dto = new RoleDTO();
        dto.setId(role.getId());
        dto.setRoleName(role.getRoleName());
        return dto; // convierte Role a DTO
    }

    private Role mapToEntity(RoleDTO dto) {
        Role role = new Role();
        role.setRoleName(dto.getRoleName());
        return role; // convierte DTO a Role
    }

    @Override
    public List<RoleDTO> findAll() {
        List<RoleDTO> result = new ArrayList<>();
        for (Role r : roleRepository.findAll()) {
            result.add(mapToDTO(r));
        }
        return result; // devuelve todos los roles
    }

    @Override
    public RoleDTO findById(Long id) {
        Role role = roleRepository.findById(id).orElse(null);
        return role != null ? mapToDTO(role) : null; // devuelve el role por id
    }

    @Override
    public List<RoleDTO> filterByName(String nombre) {
        List<RoleDTO> result = new ArrayList<>();
        for (Role r : roleRepository.findByName(nombre)) {
            result.add(mapToDTO(r));
        }
        return result; // devuelve roles que coinciden con el nombre
    }

    @Override
    public RoleDTO save(RoleDTO roleDTO) {
        return mapToDTO(roleRepository.save(mapToEntity(roleDTO))); // guarda y devuelve el role
    }

    @Override
    public void delete(Long id) {
        roleRepository.deleteById(id); // elimina el role por id
    }

    @Override
    public RoleDTO update(Long id, RoleDTO roleDTO) {
        Role role = roleRepository.findById(id).orElse(null);
        if (role != null) {
            role.setRoleName(roleDTO.getRoleName());
            return mapToDTO(roleRepository.save(role)); // guarda cambios y devuelve el role
        } else {
            return null; // devuelve null si no existe
        }
    }
}