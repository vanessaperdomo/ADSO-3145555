package com.sena.test.IService.ISecurityService;

import java.util.List;
import com.sena.test.DTO.SecurityDTO.RoleDTO;

public interface IRoleService {

    public List<RoleDTO> findAll(); // busca todos

    public RoleDTO findById(Long id); // busca por id

    public List<RoleDTO> filterByName(String nombre); // filtra por nombre

    public RoleDTO save(RoleDTO roleDTO); // guarda

    public void delete(Long id); // elimina por id

    public RoleDTO update(Long id, RoleDTO roleDTO); // actualiza
}