package com.sena.test.Service.SecurityService;

import com.sena.test.DTO.SecurityDTO.PersonDto;
import com.sena.test.Entity.Security.Person;
import com.sena.test.Entity.Security.TypeDocument;
import com.sena.test.Entity.Security.StudyGroup;
import com.sena.test.IRepository.ISecurityRepository.IPersonRepository;
import com.sena.test.IRepository.ISecurityRepository.ITypeDocumentRepository;
import com.sena.test.IRepository.ISecurityRepository.IStudyGroupRepository;
import com.sena.test.IService.ISecurityService.IPersonService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
public class PersonService implements IPersonService {

    @Autowired
    private IPersonRepository repository;

    @Autowired
    private ITypeDocumentRepository typeDocumentRepository;

    @Autowired
    private IStudyGroupRepository studyGroupRepository;

    private PersonDto toDto(Person e) {
        PersonDto dto = new PersonDto();
        dto.setId(e.getId());
        dto.setFirstName(e.getFirstName());
        dto.setLastName(e.getLastName());
        dto.setDocumentNumber(e.getDocumentNumber());
        dto.setEmail(e.getEmail());
        dto.setPhone(e.getPhone());
        dto.setTypeDocumentId(e.getTypeDocument().getId());
        if (e.getStudyGroup() != null) {
            dto.setStudyGroupId(e.getStudyGroup().getId());
        }
        return dto;
    }

    private Person toEntity(PersonDto dto) {
        Person e = new Person();
        e.setFirstName(dto.getFirstName());
        e.setLastName(dto.getLastName());
        e.setDocumentNumber(dto.getDocumentNumber());
        e.setEmail(dto.getEmail());
        e.setPhone(dto.getPhone());
        TypeDocument td = typeDocumentRepository.findById(dto.getTypeDocumentId()).orElse(null);
        e.setTypeDocument(td);
        if (dto.getStudyGroupId() != null) {
            StudyGroup sg = studyGroupRepository.findById(dto.getStudyGroupId()).orElse(null);
            e.setStudyGroup(sg);
        }
        return e;
    }

    @Override
    public List<PersonDto> getAll() {
        return repository.findAll().stream().map(this::toDto).collect(Collectors.toList());
    }

    @Override
    public PersonDto getById(UUID id) {
        Person e = repository.findById(id).orElse(null);
        if (e == null)
            return null;
        return toDto(e);
    }

    @Override
    public PersonDto create(PersonDto dto) {
        return toDto(repository.save(toEntity(dto)));
    }

    @Override
    public PersonDto update(UUID id, PersonDto dto) {
        Person e = repository.findById(id).orElse(null);
        if (e == null)
            return null;
        e.setFirstName(dto.getFirstName());
        e.setLastName(dto.getLastName());
        e.setDocumentNumber(dto.getDocumentNumber());
        e.setEmail(dto.getEmail());
        e.setPhone(dto.getPhone());
        TypeDocument td = typeDocumentRepository.findById(dto.getTypeDocumentId()).orElse(null);
        e.setTypeDocument(td);
        if (dto.getStudyGroupId() != null) {
            StudyGroup sg = studyGroupRepository.findById(dto.getStudyGroupId()).orElse(null);
            e.setStudyGroup(sg);
        }
        return toDto(repository.save(e));
    }

    @Override
    public void delete(UUID id) {
        repository.deleteById(id);
    }
}