package com.sena.test.Controller.SecurityController;

import com.sena.test.DTO.SecurityDTO.TypeDocumentDto;
import com.sena.test.Service.SecurityService.TypeDocumentService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/type-document")
@CrossOrigin(origins = "*")
public class TypeDocumentController {

    @Autowired
    private TypeDocumentService typeDocumentService;

    @GetMapping
    public List<TypeDocumentDto> getAll() {
        return typeDocumentService.getAll();
    }

    @GetMapping("/{id}")
    public TypeDocumentDto getById(@PathVariable UUID id) {
        return typeDocumentService.getById(id);
    }

    @PostMapping
    public TypeDocumentDto create(@RequestBody TypeDocumentDto dto) {
        return typeDocumentService.create(dto);
    }

    @PutMapping("/{id}")
    public TypeDocumentDto update(@PathVariable UUID id, @RequestBody TypeDocumentDto dto) {
        return typeDocumentService.update(id, dto);
    }

    @DeleteMapping("/{id}")
    public String delete(@PathVariable UUID id) {
        typeDocumentService.delete(id);
        return "Eliminado exitosamente";
    }
}