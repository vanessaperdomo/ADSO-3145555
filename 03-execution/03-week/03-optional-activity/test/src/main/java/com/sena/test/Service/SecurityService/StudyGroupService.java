package com.sena.test.Service.SecurityService;

import com.sena.test.DTO.SecurityDTO.StudyGroupDto;
import com.sena.test.Entity.Security.AcademicProgram;
import com.sena.test.Entity.Security.StudyGroup;
import com.sena.test.IRepository.ISecurityRepository.IAcademicProgramRepository;
import com.sena.test.IRepository.ISecurityRepository.IStudyGroupRepository;
import com.sena.test.IService.ISecurityService.IStudyGroupService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
public class StudyGroupService implements IStudyGroupService {

    @Autowired
    private IStudyGroupRepository repository;

    @Autowired
    private IAcademicProgramRepository academicProgramRepository;

    private StudyGroupDto toDto(StudyGroup e) {
        StudyGroupDto dto = new StudyGroupDto();
        dto.setId(e.getId());
        dto.setGroupCode(e.getGroupCode());
        dto.setAcademicProgramId(e.getAcademicProgram().getId());
        return dto;
    }

    private StudyGroup toEntity(StudyGroupDto dto) {
        StudyGroup e = new StudyGroup();
        e.setGroupCode(dto.getGroupCode());
        AcademicProgram ap = academicProgramRepository.findById(dto.getAcademicProgramId()).orElse(null);
        e.setAcademicProgram(ap);
        return e;
    }

    @Override
    public List<StudyGroupDto> getAll() {
        return repository.findAll().stream().map(this::toDto).collect(Collectors.toList());
    }

    @Override
    public StudyGroupDto getById(UUID id) {
        StudyGroup e = repository.findById(id).orElse(null);
        if (e == null)
            return null;
        return toDto(e);
    }

    @Override
    public StudyGroupDto create(StudyGroupDto dto) {
        return toDto(repository.save(toEntity(dto)));
    }

    @Override
    public StudyGroupDto update(UUID id, StudyGroupDto dto) {
        StudyGroup e = repository.findById(id).orElse(null);
        if (e == null)
            return null;
        e.setGroupCode(dto.getGroupCode());
        AcademicProgram ap = academicProgramRepository.findById(dto.getAcademicProgramId()).orElse(null);
        e.setAcademicProgram(ap);
        return toDto(repository.save(e));
    }

    @Override
    public void delete(UUID id) {
        repository.deleteById(id);
    }
}
