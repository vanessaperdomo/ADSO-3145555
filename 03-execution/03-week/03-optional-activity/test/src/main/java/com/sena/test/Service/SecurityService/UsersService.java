package com.sena.test.Service.SecurityService;

import com.sena.test.DTO.SecurityDTO.UsersDto;
import com.sena.test.Entity.Security.Person;
import com.sena.test.Entity.Security.Users;
import com.sena.test.IRepository.ISecurityRepository.IPersonRepository;
import com.sena.test.IRepository.ISecurityRepository.IUsersRepository;
import com.sena.test.IService.ISecurityService.IUsersService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
public class UsersService implements IUsersService {

    @Autowired
    private IUsersRepository repository;

    @Autowired
    private IPersonRepository personRepository;

    private UsersDto toDto(Users e) {
        UsersDto dto = new UsersDto();
        dto.setId(e.getId());
        dto.setUsername(e.getUsername());
        dto.setPassword(e.getPassword());
        dto.setActive(e.getActive());
        dto.setPersonId(e.getPerson().getId());
        return dto;
    }

    private Users toEntity(UsersDto dto) {
        Users e = new Users();
        e.setUsername(dto.getUsername());
        e.setPassword(dto.getPassword());
        e.setActive(dto.getActive() != null ? dto.getActive() : true);
        Person person = personRepository.findById(dto.getPersonId()).orElse(null);
        e.setPerson(person);
        return e;
    }

    @Override
    public List<UsersDto> getAll() {
        return repository.findAll().stream().map(this::toDto).collect(Collectors.toList());
    }

    @Override
    public UsersDto getById(UUID id) {
        Users e = repository.findById(id).orElse(null);
        if (e == null)
            return null;
        return toDto(e);
    }

    @Override
    public UsersDto create(UsersDto dto) {
        return toDto(repository.save(toEntity(dto)));
    }

    @Override
    public UsersDto update(UUID id, UsersDto dto) {
        Users e = repository.findById(id).orElse(null);
        if (e == null)
            return null;
        e.setUsername(dto.getUsername());
        e.setPassword(dto.getPassword());
        e.setActive(dto.getActive());
        Person person = personRepository.findById(dto.getPersonId()).orElse(null);
        e.setPerson(person);
        return toDto(repository.save(e));
    }

    @Override
    public void delete(UUID id) {
        repository.deleteById(id);
    }
}
