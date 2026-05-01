package com.sena.test.Service.SecurityService;

import com.sena.test.DTO.SecurityDTO.CustomerDto;
import com.sena.test.Entity.Security.Customer;
import com.sena.test.Entity.Security.CustomerType;
import com.sena.test.Entity.Security.Person;
import com.sena.test.IRepository.ISecurityRepository.ICustomerRepository;
import com.sena.test.IRepository.ISecurityRepository.ICustomerTypeRepository;
import com.sena.test.IRepository.ISecurityRepository.IPersonRepository;
import com.sena.test.IService.ISecurityService.ICustomerService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
public class CustomerService implements ICustomerService {

    @Autowired
    private ICustomerRepository repository;

    @Autowired
    private IPersonRepository personRepository;

    @Autowired
    private ICustomerTypeRepository customerTypeRepository;

    private CustomerDto toDto(Customer e) {
        CustomerDto dto = new CustomerDto();
        dto.setId(e.getId());
        dto.setPersonId(e.getPerson().getId());
        dto.setCustomerTypeId(e.getCustomerType().getId());
        return dto;
    }

    private Customer toEntity(CustomerDto dto) {
        Customer e = new Customer();
        Person person = personRepository.findById(dto.getPersonId()).orElse(null);
        e.setPerson(person);
        CustomerType ct = customerTypeRepository.findById(dto.getCustomerTypeId()).orElse(null);
        e.setCustomerType(ct);
        return e;
    }

    @Override
    public List<CustomerDto> getAll() {
        return repository.findAll().stream().map(this::toDto).collect(Collectors.toList());
    }

    @Override
    public CustomerDto getById(UUID id) {
        Customer e = repository.findById(id).orElse(null);
        if (e == null)
            return null;
        return toDto(e);
    }

    @Override
    public CustomerDto create(CustomerDto dto) {
        return toDto(repository.save(toEntity(dto)));
    }

    @Override
    public CustomerDto update(UUID id, CustomerDto dto) {
        Customer e = repository.findById(id).orElse(null);
        if (e == null)
            return null;
        Person person = personRepository.findById(dto.getPersonId()).orElse(null);
        e.setPerson(person);
        CustomerType ct = customerTypeRepository.findById(dto.getCustomerTypeId()).orElse(null);
        e.setCustomerType(ct);
        return toDto(repository.save(e));
    }

    @Override
    public void delete(UUID id) {
        repository.deleteById(id);
    }
}
