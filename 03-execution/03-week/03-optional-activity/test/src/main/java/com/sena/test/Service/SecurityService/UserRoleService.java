package com.sena.test.Service.SecurityService;

import com.sena.test.DTO.SecurityDTO.UserRoleDto;
import com.sena.test.Entity.Security.Role;
import com.sena.test.Entity.Security.UserRole;
import com.sena.test.Entity.Security.UserRoleId;
import com.sena.test.Entity.Security.Users;
import com.sena.test.IRepository.ISecurityRepository.IRoleRepository;
import com.sena.test.IRepository.ISecurityRepository.IUserRoleRepository;
import com.sena.test.IRepository.ISecurityRepository.IUsersRepository;
import com.sena.test.IService.ISecurityService.IUserRoleService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
public class UserRoleService implements IUserRoleService {

    @Autowired
    private IUserRoleRepository repository;

    @Autowired
    private IUsersRepository usersRepository;

    @Autowired
    private IRoleRepository roleRepository;

    private UserRoleDto toDto(UserRole e) {
        UserRoleDto dto = new UserRoleDto();
        dto.setUserId(e.getId().getUserId());
        dto.setRoleId(e.getId().getRoleId());
        return dto;
    }

    @Override
    public List<UserRoleDto> getAll() {
        return repository.findAll().stream().map(this::toDto).collect(Collectors.toList());
    }

    @Override
    public UserRoleDto create(UserRoleDto dto) {
        UserRole e = new UserRole();
        UserRoleId urId = new UserRoleId(dto.getUserId(), dto.getRoleId());
        e.setId(urId);
        Users user = usersRepository.findById(dto.getUserId()).orElse(null);
        e.setUsers(user);
        Role role = roleRepository.findById(dto.getRoleId()).orElse(null);
        e.setRole(role);
        return toDto(repository.save(e));
    }

    @Override
    public void delete(UUID userId, UUID roleId) {
        repository.deleteById(new UserRoleId(userId, roleId));
    }
}
