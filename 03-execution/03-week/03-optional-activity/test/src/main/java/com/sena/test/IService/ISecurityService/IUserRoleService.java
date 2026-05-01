package com.sena.test.IService.ISecurityService;

import com.sena.test.DTO.SecurityDTO.UserRoleDto;
import java.util.List;
import java.util.UUID;

public interface IUserRoleService {
    List<UserRoleDto> getAll();

    UserRoleDto create(UserRoleDto dto);

    void delete(UUID userId, UUID roleId);
}