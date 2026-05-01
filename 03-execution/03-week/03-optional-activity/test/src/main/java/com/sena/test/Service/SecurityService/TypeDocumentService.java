package com.sena.test.Service.SecurityService;

import com.sena.test.DTO.SecurityDTO.TypeDocumentDto;
import com.sena.test.Entity.Security.TypeDocument;
import com.sena.test.IRepository.ISecurityRepository.ITypeDocumentRepository;
import com.sena.test.IService.ISecurityService.ITypeDocumentService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
public class TypeDocumentService implements ITypeDocumentService {

    @Autowired
    private ITypeDocumentRepository repository;

    // Convierte Entity a DTO
    private TypeDocumentDto toDto(TypeDocument e) {
        TypeDocumentDto dto = new TypeDocumentDto();
        dto.setId(e.getId());
        dto.setName(e.getName());
        return dto;
    }

    // Convierte DTO a Entity
    private TypeDocument toEntity(TypeDocumentDto dto) {
        TypeDocument e = new TypeDocument();
        e.setName(dto.getName());
        return e;
    }

    @Override
    public List<TypeDocumentDto> getAll() {
        return repository.findAll().stream().map(this::toDto).collect(Collectors.toList());
    }

    @Override
    public TypeDocumentDto getById(UUID id) {
        TypeDocument e = repository.findById(id).orElse(null);
        if (e == null)
            return null;
        return toDto(e);
    }

    @Override
    public TypeDocumentDto create(TypeDocumentDto dto) {
        return toDto(repository.save(toEntity(dto)));
    }

    @Override
    public TypeDocumentDto update(UUID id, TypeDocumentDto dto) {
        TypeDocument e = repository.findById(id).orElse(null);
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