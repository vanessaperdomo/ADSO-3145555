package com.sena.test.IService.ISecurityService;

import com.sena.test.DTO.SecurityDTO.UsersDto;
import java.util.List;
import java.util.UUID;

public interface IUsersService {
    List<UsersDto> getAll();

    UsersDto getById(UUID id);

    UsersDto create(UsersDto dto);

    UsersDto update(UUID id, UsersDto dto);

    void delete(UUID id);
}