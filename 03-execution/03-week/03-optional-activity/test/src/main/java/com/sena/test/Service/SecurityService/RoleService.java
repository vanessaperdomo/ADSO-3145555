package com.sena.test.Service.SecurityService;

import com.sena.test.DTO.SecurityDTO.RoleDto;
import com.sena.test.Entity.Security.Role;
import com.sena.test.IRepository.ISecurityRepository.IRoleRepository;
import com.sena.test.IService.ISecurityService.IRoleService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
public class RoleService implements IRoleService {

    @Autowired
    private IRoleRepository repository;

    private RoleDto toDto(Role e) {
        RoleDto dto = new RoleDto();
        dto.setId(e.getId());
        dto.setRoleName(e.getRoleName());
        return dto;
    }

    private Role toEntity(RoleDto dto) {
        Role e = new Role();
        e.setRoleName(dto.getRoleName());
        return e;
    }

    @Override
    public List<RoleDto> getAll() {
        return repository.findAll().stream().map(this::toDto).collect(Collectors.toList());
    }

    @Override
    public RoleDto getById(UUID id) {
        Role e = repository.findById(id).orElse(null);
        if (e == null)
            return null;
        return toDto(e);
    }

    @Override
    public RoleDto create(RoleDto dto) {
        return toDto(repository.save(toEntity(dto)));
    }

    @Override
    public RoleDto update(UUID id, RoleDto dto) {
        Role e = repository.findById(id).orElse(null);
        if (e == null)
            return null;
        e.setRoleName(dto.getRoleName());
        return toDto(repository.save(e));
    }

    @Override
    public void delete(UUID id) {
        repository.deleteById(id);
    }
}