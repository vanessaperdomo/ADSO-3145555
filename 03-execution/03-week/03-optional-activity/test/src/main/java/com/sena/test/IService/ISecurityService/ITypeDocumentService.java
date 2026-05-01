package com.sena.test.IService.ISecurityService;

import com.sena.test.DTO.SecurityDTO.TypeDocumentDto;
import java.util.List;
import java.util.UUID;

public interface ITypeDocumentService {
    List<TypeDocumentDto> getAll();

    TypeDocumentDto getById(UUID id);

    TypeDocumentDto create(TypeDocumentDto dto);

    TypeDocumentDto update(UUID id, TypeDocumentDto dto);

    void delete(UUID id);
}