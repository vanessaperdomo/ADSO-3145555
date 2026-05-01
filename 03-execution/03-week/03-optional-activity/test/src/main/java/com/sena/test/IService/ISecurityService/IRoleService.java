package com.sena.test.IService.ISecurityService;

import com.sena.test.DTO.SecurityDTO.RoleDto;
import java.util.List;
import java.util.UUID;

public interface IRoleService {
    List<RoleDto> getAll();

    RoleDto getById(UUID id);

    RoleDto create(RoleDto dto);

    RoleDto update(UUID id, RoleDto dto);

    void delete(UUID id);
}