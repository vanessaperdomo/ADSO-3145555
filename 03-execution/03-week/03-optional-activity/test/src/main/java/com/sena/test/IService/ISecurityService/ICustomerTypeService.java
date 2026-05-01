package com.sena.test.IService.ISecurityService;

import com.sena.test.DTO.SecurityDTO.CustomerTypeDto;
import java.util.List;
import java.util.UUID;

public interface ICustomerTypeService {
    List<CustomerTypeDto> getAll();

    CustomerTypeDto getById(UUID id);

    CustomerTypeDto create(CustomerTypeDto dto);

    CustomerTypeDto update(UUID id, CustomerTypeDto dto);

    void delete(UUID id);
}