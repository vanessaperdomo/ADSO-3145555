package com.sena.test.Service.SecurityService;

import com.sena.test.DTO.SecurityDTO.AcademicProgramDto;
import com.sena.test.Entity.Security.AcademicProgram;
import com.sena.test.IRepository.ISecurityRepository.IAcademicProgramRepository;
import com.sena.test.IService.ISecurityService.IAcademicProgramService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
public class AcademicProgramService implements IAcademicProgramService {

    @Autowired
    private IAcademicProgramRepository repository;

    private AcademicProgramDto toDto(AcademicProgram e) {
        AcademicProgramDto dto = new AcademicProgramDto();
        dto.setId(e.getId());
        dto.setProgramName(e.getProgramName());
        return dto;
    }

    private AcademicProgram toEntity(AcademicProgramDto dto) {
        AcademicProgram e = new AcademicProgram();
        e.setProgramName(dto.getProgramName());
        return e;
    }

    @Override
    public List<AcademicProgramDto> getAll() {
        return repository.findAll().stream().map(this::toDto).collect(Collectors.toList());
    }

    @Override
    public AcademicProgramDto getById(UUID id) {
        AcademicProgram e = repository.findById(id).orElse(null);
        if (e == null)
            return null;
        return toDto(e);
    }

    @Override
    public AcademicProgramDto create(AcademicProgramDto dto) {
        return toDto(repository.save(toEntity(dto)));
    }

    @Override
    public AcademicProgramDto update(UUID id, AcademicProgramDto dto) {
        AcademicProgram e = repository.findById(id).orElse(null);
        if (e == null)
            return null;
        e.setProgramName(dto.getProgramName());
        return toDto(repository.save(e));
    }

    @Override
    public void delete(UUID id) {
        repository.deleteById(id);
    }
}