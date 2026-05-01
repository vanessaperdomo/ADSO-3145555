package com.sena.test.Service.SecurityService;

import com.sena.test.DTO.SecurityDTO.CustomerTypeDto;
import com.sena.test.Entity.Security.CustomerType;
import com.sena.test.IRepository.ISecurityRepository.ICustomerTypeRepository;
import com.sena.test.IService.ISecurityService.ICustomerTypeService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
public class CustomerTypeService implements ICustomerTypeService {

    @Autowired
    private ICustomerTypeRepository repository;

    private CustomerTypeDto toDto(CustomerType e) {
        CustomerTypeDto dto = new CustomerTypeDto();
        dto.setId(e.getId());
        dto.setName(e.getName());
        return dto;
    }

    private CustomerType toEntity(CustomerTypeDto dto) {
        CustomerType e = new CustomerType();
        e.setName(dto.getName());
        return e;
    }

    @Override
    public List<CustomerTypeDto> getAll() {
        return repository.findAll().stream().map(this::toDto).collect(Collectors.toList());
    }

    @Override
    public CustomerTypeDto getById(UUID id) {
        CustomerType e = repository.findById(id).orElse(null);
        if (e == null)
            return null;
        return toDto(e);
    }

    @Override
    public CustomerTypeDto create(CustomerTypeDto dto) {
        return toDto(repository.save(toEntity(dto)));
    }

    @Override
    public CustomerTypeDto update(UUID id, CustomerTypeDto dto) {
        CustomerType e = repository.findById(id).orElse(null);
        if (e == null)
            return null;
        e.setName(dto.getName());
        return toDto(repository.save(e));
    }

    @Override
    public void delete(UUID id) {
        repository.deleteById(id);
    }
}