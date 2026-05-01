package com.sena.test.Controller.SecurityController;

import com.sena.test.DTO.SecurityDTO.PersonDto;
import com.sena.test.Service.SecurityService.PersonService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/person")
@CrossOrigin(origins = "*")
public class PersonController {

    @Autowired
    private PersonService personService;

    @GetMapping
    public List<PersonDto> getAll() {
        return personService.getAll();
    }

    @GetMapping("/{id}")
    public PersonDto getById(@PathVariable UUID id) {
        return personService.getById(id);
    }

    @PostMapping
    public PersonDto create(@RequestBody PersonDto dto) {
        return personService.create(dto);
    }

    @PutMapping("/{id}")
    public PersonDto update(@PathVariable UUID id, @RequestBody PersonDto dto) {
        return personService.update(id, dto);
    }

    @DeleteMapping("/{id}")
    public String delete(@PathVariable UUID id) {
        personService.delete(id);
        return "Eliminado exitosamente";
    }
}
