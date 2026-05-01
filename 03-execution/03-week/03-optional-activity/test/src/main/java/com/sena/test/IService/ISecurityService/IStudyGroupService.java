package com.sena.test.IService.ISecurityService;

import com.sena.test.DTO.SecurityDTO.StudyGroupDto;
import java.util.List;
import java.util.UUID;

public interface IStudyGroupService {
    List<StudyGroupDto> getAll();

    StudyGroupDto getById(UUID id);

    StudyGroupDto create(StudyGroupDto dto);

    StudyGroupDto update(UUID id, StudyGroupDto dto);

    void delete(UUID id);
}