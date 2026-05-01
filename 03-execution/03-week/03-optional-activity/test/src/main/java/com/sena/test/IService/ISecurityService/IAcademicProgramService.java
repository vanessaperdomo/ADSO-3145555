package com.sena.test.IService.ISecurityService;

import com.sena.test.DTO.SecurityDTO.AcademicProgramDto;
import java.util.List;
import java.util.UUID;

public interface IAcademicProgramService {
    List<AcademicProgramDto> getAll();

    AcademicProgramDto getById(UUID id);

    AcademicProgramDto create(AcademicProgramDto dto);

    AcademicProgramDto update(UUID id, AcademicProgramDto dto);

    void delete(UUID id);
}