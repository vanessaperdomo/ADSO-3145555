package com.sena.test.IService.ISecurityService;

import java.util.List;
import com.sena.test.DTO.SecurityDTO.RoleDTO;

public interface IRoleService {
    List<RoleDTO> findAll();

    RoleDTO findById(Long id);

    RoleDTO save(RoleDTO roleDTO);

    RoleDTO update(Long id, RoleDTO roleDTO);

    void delete(Long id);

    List<RoleDTO> findByName(String roleName);
}