package com.sena.test.IService.ISecurityService;

import com.sena.test.DTO.SecurityDTO.CustomerDto;
import java.util.List;
import java.util.UUID;

public interface ICustomerService {
    List<CustomerDto> getAll();

    CustomerDto getById(UUID id);

    CustomerDto create(CustomerDto dto);

    CustomerDto update(UUID id, CustomerDto dto);

    void delete(UUID id);
}