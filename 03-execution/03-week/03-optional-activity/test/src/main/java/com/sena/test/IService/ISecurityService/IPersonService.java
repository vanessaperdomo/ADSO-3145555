package com.sena.test.IService.ISecurityService;

import com.sena.test.DTO.SecurityDTO.PersonDto;
import java.util.List;
import java.util.UUID;

public interface IPersonService {
    List<PersonDto> getAll();

    PersonDto getById(UUID id);

    PersonDto create(PersonDto dto);

    PersonDto update(UUID id, PersonDto dto);

    void delete(UUID id);
}